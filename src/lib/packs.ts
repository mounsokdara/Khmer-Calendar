export const PACKS = [
  {
    id: "android",
    file: "/native/KhmerCalendar.apk",
    name: "KhmerCalendar.apk",
    icon: "android",
    titleKey: "exportApk" as const,
    subKey: "exportApkSub" as const,
  },
  {
    id: "windows",
    file: "/native/KhmerCalendar.exe",
    name: "KhmerCalendar.exe",
    icon: "windows",
    titleKey: "exportWindows" as const,
    subKey: "exportWindowsSub" as const,
  },
  {
    id: "macos",
    file: "/native/KhmerCalendar.dmg",
    name: "KhmerCalendar.dmg",
    icon: "macos",
    titleKey: "exportMac" as const,
    subKey: "exportMacSub" as const,
  },
  {
    id: "linux",
    file: "/native/KhmerCalendar.AppImage",
    name: "KhmerCalendar.AppImage",
    icon: "linux",
    titleKey: "exportLinux" as const,
    subKey: "exportLinuxSub" as const,
  },
  {
    id: "project",
    file: "/native/KhmerCalendar-project.zip",
    name: "KhmerCalendar-project.zip",
    icon: "folder_zip",
    titleKey: "downloadProject" as const,
    subKey: "downloadProjectSub" as const,
  },
] as const;

export type PackId = (typeof PACKS)[number]["id"];

export function packById(id: string) {
  return PACKS.find((p) => p.id === id);
}

export async function savePack(file: string, name: string) {
  const res = await fetch(file);
  if (!res.ok) throw new Error(`Http ${res.status}`);
  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  a.remove();
  window.setTimeout(() => URL.revokeObjectURL(url), 2000);
}
