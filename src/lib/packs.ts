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

const PACK_MIME: Record<string, string> = {
  apk: "application/vnd.android.package-archive",
  exe: "application/vnd.microsoft.portable-executable",
  dmg: "application/x-apple-diskimage",
  AppImage: "application/octet-stream",
  zip: "application/zip",
};

function looksLikeHtml(bytes: Uint8Array) {
  const head = new TextDecoder().decode(bytes.slice(0, 80)).trimStart().toLowerCase();
  return head.startsWith("<!doctype") || head.startsWith("<html") || head.startsWith("<head");
}

function looksLikeApk(bytes: Uint8Array) {
  return bytes.length > 1000 && bytes[0] === 0x50 && bytes[1] === 0x4b && bytes[2] === 0x03 && bytes[3] === 0x04;
}

export async function savePack(file: string, name: string) {
  const res = await fetch(file, { cache: "no-store" });
  if (!res.ok) throw new Error(`Http ${res.status}`);
  const buf = await res.arrayBuffer();
  const bytes = new Uint8Array(buf);
  const ctype = (res.headers.get("content-type") || "").toLowerCase();
  if (ctype.includes("text/html") || looksLikeHtml(bytes)) {
    throw new Error("pack was html");
  }
  if (name.endsWith(".apk") && !looksLikeApk(bytes)) {
    throw new Error("pack was not an apk");
  }
  const ext = name.split(".").pop() ?? "";
  const blob = new Blob([buf], { type: PACK_MIME[ext] ?? "application/octet-stream" });
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
