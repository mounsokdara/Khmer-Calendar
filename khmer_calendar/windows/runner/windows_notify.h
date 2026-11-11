#ifndef RUNNER_WINDOWS_NOTIFY_H_
#define RUNNER_WINDOWS_NOTIFY_H_

#include <string>

// Registers AppUserModelId + Start Menu shortcut so toast notifications show
// the correct app name and icon (unpackaged Windows apps).
// Uses HKCU only — no admin rights required.
bool KhmerRegisterNotificationApp(
    const std::wstring& app_name,
    const std::wstring& aumid,
    const std::wstring& icon_path);

// Runs a PowerShell script (hidden, non-blocking). Returns true if the process
// started successfully. |script| is the full script body (not a file path).
// Output is discarded; use only for side-effect scripts (notify setup, etc.).
bool KhmerRunPowerShell(const std::wstring& script, std::wstring* error_out);

// Convenience: UTF-8 entry points used by the method channel.
bool KhmerRegisterNotificationAppUtf8(const std::string& app_name,
                                      const std::string& aumid,
                                      const std::string& icon_path);
bool KhmerRunPowerShellUtf8(const std::string& script, std::string* error_out);

#endif  // RUNNER_WINDOWS_NOTIFY_H_
