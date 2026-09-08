/* Self-extracting stub: payload is a ZIP appended after this binary,
 * followed by a little-endian uint64 size and the 8-byte marker "KHCALPKG". */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <pwd.h>
#endif

static const char MARKER[] = "KHCALPKG";

static int mk_dir(const char *path) {
#ifdef _WIN32
  return CreateDirectoryA(path, NULL) || GetLastError() == ERROR_ALREADY_EXISTS;
#else
  return mkdir(path, 0755) == 0 || errno == EEXIST;
#endif
}

static int run_cmd(char *cmd) {
#ifdef _WIN32
  STARTUPINFOA si;
  PROCESS_INFORMATION pi;
  memset(&si, 0, sizeof si);
  si.cb = sizeof si;
  si.dwFlags = STARTF_USESHOWWINDOW;
  si.wShowWindow = SW_HIDE;
  memset(&pi, 0, sizeof pi);
  if (!CreateProcessA(NULL, cmd, NULL, NULL, FALSE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi))
    return 0;
  WaitForSingleObject(pi.hProcess, INFINITE);
  DWORD code = 1;
  GetExitCodeProcess(pi.hProcess, &code);
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);
  return code == 0;
#else
  return system(cmd) == 0;
#endif
}

static int launch(const char *bin, const char *args) {
#ifdef _WIN32
  char cmd[2048];
  snprintf(cmd, sizeof cmd, "\"%s\" %s", bin, args);
  STARTUPINFOA si;
  PROCESS_INFORMATION pi;
  memset(&si, 0, sizeof si);
  si.cb = sizeof si;
  memset(&pi, 0, sizeof pi);
  if (!CreateProcessA(bin, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
    return 0;
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);
  return 1;
#else
  if (fork() == 0) {
    execl(bin, bin, args, (char *)NULL);
    _exit(127);
  }
  return 1;
#endif
}

#ifdef _WIN32
int WINAPI WinMain(HINSTANCE a, HINSTANCE b, LPSTR c, int d) {
  (void)a;
  (void)b;
  (void)c;
  (void)d;
  char self[MAX_PATH];
  GetModuleFileNameA(NULL, self, MAX_PATH);
  char dest[MAX_PATH];
  if (!GetEnvironmentVariableA("LOCALAPPDATA", dest, MAX_PATH))
    GetTempPathA(MAX_PATH, dest);
  strncat(dest, "\\KhmerCalendar", MAX_PATH - strlen(dest) - 1);
#else
int main(int argc, char **argv) {
  char self[4096];
  memset(self, 0, sizeof self);
#ifdef __linux__
  if (readlink("/proc/self/exe", self, sizeof self - 1) < 0)
    strncpy(self, argv[0], sizeof self - 1);
#else
  strncpy(self, argv[0] ? argv[0] : "", sizeof self - 1);
#endif
  const char *home = getenv("HOME");
  if (!home) {
    struct passwd *pw = getpwuid(getuid());
    home = pw ? pw->pw_dir : "/tmp";
  }
  char dest[4096];
  snprintf(dest, sizeof dest, "%s/.local/share/khmer-calendar", home);
#endif

  mk_dir(dest);
#ifdef _WIN32
  char zip_path[MAX_PATH];
  snprintf(zip_path, sizeof zip_path, "%s\\payload.zip", dest);
#else
  { char tmp[64]; snprintf(tmp, sizeof tmp, "%s/.local/share", home); mk_dir(tmp); }
  char zip_path[4096];
  snprintf(zip_path, sizeof zip_path, "%s/payload.zip", dest);
#endif

  FILE *in = fopen(self, "rb");
  if (!in) return 1;
  if (fseek(in, 0, SEEK_END) != 0) {
    fclose(in);
    return 1;
  }
  long total = ftell(in);
  if (total < 24) {
    fclose(in);
    return 1;
  }
  if (fseek(in, total - 16, SEEK_SET) != 0) {
    fclose(in);
    return 1;
  }
  unsigned char tail[16];
  if (fread(tail, 1, 16, in) != 16) {
    fclose(in);
    return 1;
  }
  if (memcmp(tail + 8, MARKER, 8) != 0) {
    fclose(in);
    return 1;
  }
  uint64_t zsize = 0;
  for (int i = 0; i < 8; i++) zsize |= ((uint64_t)tail[i]) << (8 * i);
  long zoff = total - 16 - (long)zsize;
  if (zoff < 0 || zsize == 0) {
    fclose(in);
    return 1;
  }
  if (fseek(in, zoff, SEEK_SET) != 0) {
    fclose(in);
    return 1;
  }
  FILE *out = fopen(zip_path, "wb");
  if (!out) {
    fclose(in);
    return 1;
  }
  char buf[1 << 16];
  uint64_t left = zsize;
  while (left) {
    size_t n = left > sizeof buf ? sizeof buf : (size_t)left;
    n = fread(buf, 1, n, in);
    if (!n) break;
    fwrite(buf, 1, n, out);
    left -= n;
  }
  fclose(out);
  fclose(in);

#ifdef _WIN32
  char cmd[2048];
  snprintf(cmd, sizeof cmd, "tar -xf \"%s\" -C \"%s\"", zip_path, dest);
  if (!run_cmd(cmd)) {
    snprintf(cmd, sizeof cmd,
             "powershell -NoProfile -Command \"Expand-Archive -Force -Path '%s' -DestinationPath '%s'\"",
             zip_path, dest);
    run_cmd(cmd);
  }
  char bin[MAX_PATH];
  snprintf(bin, sizeof bin, "%s\\bin\\KhmerCalendar.exe", dest);
  char args[1024];
  snprintf(args, sizeof args, "--path=\"%s\" --res-mode=directory", dest);
  if (!launch(bin, args)) return 1;
#else
  char cmd[4096];
  snprintf(cmd, sizeof cmd, "unzip -o -q \"%s\" -d \"%s\" 2>/dev/null || python3 -m zipfile -e \"%s\" \"%s\"",
           zip_path, dest, zip_path, dest);
  run_cmd(cmd);
  char bin[4096];
  snprintf(bin, sizeof bin, "%s/bin/KhmerCalendar", dest);
  chmod(bin, 0755);
  char args[1024];
  snprintf(args, sizeof args, "--path=%s --res-mode=directory", dest);
  if (fork() == 0) {
    execl(bin, bin, "--path", dest, "--res-mode=directory", (char *)NULL);
    _exit(127);
  }
#endif
  return 0;
}
#ifndef _WIN32
#endif
