#include "flutter_window.h"

#include <optional>
#include <string>

#include <flutter/standard_method_codec.h>

#include "autostart.h"
#include "flutter/generated_plugin_registrant.h"
#include "windows_notify.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void FlutterWindow::RegisterAutostartChannel() {
  autostart_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "khmer.autostart",
          &flutter::StandardMethodCodec::GetInstance());
  autostart_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        const std::string& method = call.method_name();
        if (method == "enable") {
          result->Success(flutter::EncodableValue(KhmerAutostartEnable()));
        } else if (method == "disable") {
          result->Success(flutter::EncodableValue(KhmerAutostartDisable()));
        } else if (method == "isEnabled") {
          result->Success(flutter::EncodableValue(KhmerAutostartIsEnabled()));
        } else if (method == "ensureRunning") {
          result->Success(
              flutter::EncodableValue(KhmerAutostartEnsureRunning()));
        } else {
          result->NotImplemented();
        }
      });
}

void FlutterWindow::RegisterWindowsChannel() {
  windows_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "khmer.windows",
          &flutter::StandardMethodCodec::GetInstance());
  windows_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        const std::string& method = call.method_name();
        if (method == "registerNotifyApp") {
          std::string app_name = "Khmer Calendar";
          std::string aumid = "MounSokdara.KhmerCalendar";
          std::string icon;
          if (const auto* args =
                  std::get_if<flutter::EncodableMap>(call.arguments())) {
            auto name_it = args->find(flutter::EncodableValue("appName"));
            if (name_it != args->end()) {
              if (const auto* s = std::get_if<std::string>(&name_it->second)) {
                app_name = *s;
              }
            }
            auto id_it = args->find(flutter::EncodableValue("aumid"));
            if (id_it != args->end()) {
              if (const auto* s = std::get_if<std::string>(&id_it->second)) {
                aumid = *s;
              }
            }
            auto icon_it = args->find(flutter::EncodableValue("iconPath"));
            if (icon_it != args->end()) {
              if (const auto* s = std::get_if<std::string>(&icon_it->second)) {
                icon = *s;
              }
            }
          }
          result->Success(flutter::EncodableValue(
              KhmerRegisterNotificationAppUtf8(app_name, aumid, icon)));
        } else if (method == "runPowerShell") {
          std::string script;
          if (const auto* args =
                  std::get_if<flutter::EncodableMap>(call.arguments())) {
            auto it = args->find(flutter::EncodableValue("script"));
            if (it != args->end()) {
              if (const auto* s = std::get_if<std::string>(&it->second)) {
                script = *s;
              }
            }
          } else if (const auto* s =
                         std::get_if<std::string>(call.arguments())) {
            script = *s;
          }
          std::string err;
          bool ok = KhmerRunPowerShellUtf8(script, &err);
          if (ok) {
            result->Success(flutter::EncodableValue(true));
          } else {
            result->Error("ps_failed", err.empty() ? "PowerShell failed" : err);
          }
        } else {
          result->NotImplemented();
        }
      });
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  RegisterAutostartChannel();
  RegisterWindowsChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  if (background_) {
    // Hidden tool-style window: no taskbar entry, never shown, not activatable.
    HWND hwnd = GetHandle();
    if (hwnd != nullptr) {
      LONG_PTR ex = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
      SetWindowLongPtr(hwnd, GWL_EXSTYLE,
                       ex | WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE |
                           WS_EX_NOINHERITLAYOUT);
      SetWindowPos(hwnd, nullptr, -32000, -32000, 1, 1,
                   SWP_NOZORDER | SWP_NOACTIVATE | SWP_HIDEWINDOW);
      ShowWindow(hwnd, SW_HIDE);
    }
  } else {
    flutter_controller_->engine()->SetNextFrameCallback([&]() {
      this->Show();
    });
    flutter_controller_->ForceRedraw();
  }

  return true;
}

void FlutterWindow::OnDestroy() {
  windows_channel_.reset();
  autostart_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (background_) {
    switch (message) {
      case WM_QUERYENDSESSION:
        // Never block Windows logoff / shutdown.
        return TRUE;
      case WM_ENDSESSION:
        break;
      case WM_CLOSE:
      case WM_QUIT:
      case WM_DESTROY:
        return 0;
      case WM_SYSCOMMAND:
        if ((wparam & 0xFFF0) == SC_CLOSE) {
          return 0;
        }
        break;
      default:
        break;
    }
  }

  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
