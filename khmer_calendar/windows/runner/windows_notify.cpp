#include "windows_notify.h"

#include <objbase.h>
#include <propkey.h>
#include <propvarutil.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <windows.h>

#include <string>
#include <thread>

#pragma comment(lib, "propsys.lib")

namespace {

std::wstring Utf8ToWide(const std::string& utf8) {
  if (utf8.empty()) return std::wstring();
  int n = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(),
                              static_cast<int>(utf8.size()), nullptr, 0);
  if (n <= 0) return std::wstring();
  std::wstring out(n, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), static_cast<int>(utf8.size()),
                      out.data(), n);
  return out;
}

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) return std::string();
  int n = WideCharToMultiByte(CP_UTF8, 0, wide.c_str(),
                              static_cast<int>(wide.size()), nullptr, 0,
                              nullptr, nullptr);
  if (n <= 0) return std::string();
  std::string out(n, '\0');
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), static_cast<int>(wide.size()),
                      out.data(), n, nullptr, nullptr);
  return out;
}

std::wstring ExePath() {
  wchar_t buf[MAX_PATH] = {};
  DWORD n = GetModuleFileNameW(nullptr, buf, MAX_PATH);
  if (n == 0 || n >= MAX_PATH) return std::wstring();
  return std::wstring(buf);
}

std::wstring DirOf(const std::wstring& path) {
  size_t slash = path.find_last_of(L"\\/");
  if (slash == std::wstring::npos) return std::wstring();
  return path.substr(0, slash);
}

std::wstring ProgramsFolder() {
  PWSTR path = nullptr;
  // Per-user Start Menu — no admin required.
  HRESULT hr = SHGetKnownFolderPath(FOLDERID_Programs, 0, nullptr, &path);
  if (FAILED(hr) || path == nullptr) return std::wstring();
  std::wstring out(path);
  CoTaskMemFree(path);
  return out;
}

bool WriteRegSz(HKEY root, const wchar_t* subkey, const wchar_t* name,
                const std::wstring& value) {
  HKEY key = nullptr;
  LONG st = RegCreateKeyExW(root, subkey, 0, nullptr, 0, KEY_SET_VALUE, nullptr,
                            &key, nullptr);
  if (st != ERROR_SUCCESS) return false;
  const BYTE* data = reinterpret_cast<const BYTE*>(value.c_str());
  DWORD bytes = static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t));
  st = RegSetValueExW(key, name, 0, REG_SZ, data, bytes);
  RegCloseKey(key);
  return st == ERROR_SUCCESS;
}

bool SetShortcutAumid(const std::wstring& lnk_path, const std::wstring& aumid,
                      const std::wstring& icon) {
  IShellLinkW* link = nullptr;
  HRESULT hr = CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER,
                                IID_PPV_ARGS(&link));
  if (FAILED(hr) || link == nullptr) return false;

  IPersistFile* file = nullptr;
  hr = link->QueryInterface(IID_PPV_ARGS(&file));
  if (FAILED(hr) || file == nullptr) {
    link->Release();
    return false;
  }

  if (GetFileAttributesW(lnk_path.c_str()) != INVALID_FILE_ATTRIBUTES) {
    file->Load(lnk_path.c_str(), STGM_READWRITE);
  }

  std::wstring exe = ExePath();
  link->SetPath(exe.c_str());
  link->SetWorkingDirectory(DirOf(exe).c_str());
  link->SetDescription(L"Khmer Calendar");
  if (!icon.empty()) {
    link->SetIconLocation(icon.c_str(), 0);
  }

  IPropertyStore* props = nullptr;
  hr = link->QueryInterface(IID_PPV_ARGS(&props));
  if (SUCCEEDED(hr) && props != nullptr) {
    PROPVARIANT pv;
    PropVariantInit(&pv);
    if (SUCCEEDED(InitPropVariantFromString(aumid.c_str(), &pv))) {
      props->SetValue(PKEY_AppUserModel_ID, pv);
      props->Commit();
      PropVariantClear(&pv);
    }
    props->Release();
  }

  hr = file->Save(lnk_path.c_str(), TRUE);
  file->Release();
  link->Release();
  return SUCCEEDED(hr);
}

}  // namespace

bool KhmerRegisterNotificationApp(const std::wstring& app_name,
                                  const std::wstring& aumid,
                                  const std::wstring& icon_path) {
  if (aumid.empty() || app_name.empty()) return false;

  // HKCU\Software\Classes\AppUserModelId\<aumid>
  std::wstring reg_path = L"Software\\Classes\\AppUserModelId\\" + aumid;
  WriteRegSz(HKEY_CURRENT_USER, reg_path.c_str(), L"DisplayName", app_name);
  std::wstring icon = icon_path.empty() ? ExePath() : icon_path;
  if (!icon.empty()) {
    WriteRegSz(HKEY_CURRENT_USER, reg_path.c_str(), L"IconUri", icon);
  }

  std::wstring folder = ProgramsFolder();
  if (folder.empty()) return false;
  if (folder.back() != L'\\' && folder.back() != L'/') folder.push_back(L'\\');
  std::wstring lnk = folder + app_name + L".lnk";
  return SetShortcutAumid(lnk, aumid, icon);
}

bool KhmerRunPowerShell(const std::wstring& script, std::wstring* error_out) {
  if (script.empty()) {
    if (error_out) *error_out = L"empty script";
    return false;
  }

  wchar_t tmp[MAX_PATH] = {};
  if (GetTempPathW(MAX_PATH, tmp) == 0) {
    if (error_out) *error_out = L"GetTempPath failed";
    return false;
  }
  std::wstring path = std::wstring(tmp) + L"khmer_ps_" +
                      std::to_wstring(GetCurrentProcessId()) + L"_" +
                      std::to_wstring(GetTickCount64()) + L".ps1";

  HANDLE h = CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                         FILE_ATTRIBUTE_TEMPORARY, nullptr);
  if (h == INVALID_HANDLE_VALUE) {
    if (error_out) *error_out = L"CreateFile failed";
    return false;
  }
  // UTF-16 LE BOM so PowerShell reads Khmer text correctly.
  const WORD bom = 0xFEFF;
  DWORD written = 0;
  WriteFile(h, &bom, sizeof(bom), &written, nullptr);
  WriteFile(h, script.c_str(),
            static_cast<DWORD>(script.size() * sizeof(wchar_t)), &written,
            nullptr);
  CloseHandle(h);

  std::wstring cmd =
      L"powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden "
      L"-File \"" +
      path + L"\"";

  STARTUPINFOW si = {};
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESHOWWINDOW;
  si.wShowWindow = SW_HIDE;
  PROCESS_INFORMATION pi = {};
  std::wstring mutable_cmd = cmd;
  BOOL ok = CreateProcessW(nullptr, mutable_cmd.data(), nullptr, nullptr, FALSE,
                           CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi);
  if (!ok) {
    if (error_out) *error_out = L"CreateProcess failed";
    DeleteFileW(path.c_str());
    return false;
  }
  // Do not block the platform thread (PowerShell takes a while to start):
  // wait on a worker thread, then clean up the temp script.
  CloseHandle(pi.hThread);
  HANDLE proc = pi.hProcess;
  std::wstring script_path = path;
  std::thread([proc, script_path]() {
    if (WaitForSingleObject(proc, 30000) == WAIT_TIMEOUT) {
      TerminateProcess(proc, 1);
    }
    CloseHandle(proc);
    DeleteFileW(script_path.c_str());
  }).detach();
  return true;
}

bool KhmerRegisterNotificationAppUtf8(const std::string& app_name,
                                      const std::string& aumid,
                                      const std::string& icon_path) {
  return KhmerRegisterNotificationApp(Utf8ToWide(app_name), Utf8ToWide(aumid),
                                      Utf8ToWide(icon_path));
}

bool KhmerRunPowerShellUtf8(const std::string& script, std::string* error_out) {
  std::wstring err;
  bool ok = KhmerRunPowerShell(Utf8ToWide(script), &err);
  if (!ok && error_out) *error_out = WideToUtf8(err);
  return ok;
}
