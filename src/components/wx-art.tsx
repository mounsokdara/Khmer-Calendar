export function WxArt({
  kind,
  className,
}: {
  kind: "clear" | "cloudy" | "rain" | "storm";
  className?: string;
}) {
  const cls = className ?? "wx-art";
  if (kind === "clear") {
    return (
      <svg className={cls} viewBox="0 0 86 62" aria-hidden="true">
        <circle cx="48" cy="28" r="14" fill="var(--wx-sun, #f5c542)" />
        {[0, 45, 90, 135, 180, 225, 270, 315].map((a) => {
          const r = (a * Math.PI) / 180;
          return (
            <line
              key={a}
              x1={48 + Math.cos(r) * 18}
              y1={28 + Math.sin(r) * 18}
              x2={48 + Math.cos(r) * 24}
              y2={28 + Math.sin(r) * 24}
              stroke="var(--wx-sun, #f5c542)"
              strokeWidth="2.4"
              strokeLinecap="round"
            />
          );
        })}
      </svg>
    );
  }
  if (kind === "rain") {
    return (
      <svg className={cls} viewBox="0 0 86 62" aria-hidden="true">
        <ellipse cx="40" cy="26" rx="18" ry="12" fill="var(--wx-cloud, #fff)" />
        <ellipse cx="54" cy="28" rx="14" ry="10" fill="var(--wx-cloud-dim, #eef2f7)" />
        <path d="M30 42 l4 10 M42 42 l4 10 M54 42 l4 10" stroke="var(--wx-rain, #7ec8e3)" strokeWidth="3" strokeLinecap="round" />
      </svg>
    );
  }
  if (kind === "storm") {
    return (
      <svg className={cls} viewBox="0 0 86 62" aria-hidden="true">
        <ellipse cx="40" cy="24" rx="18" ry="12" fill="#c5c9d4" />
        <ellipse cx="54" cy="26" rx="14" ry="10" fill="#9aa0b0" />
        <path d="M48 34 L40 46 H48 L42 58 L58 42 H50 L56 34 Z" fill="#f5c542" />
      </svg>
    );
  }
  return (
    <svg className={cls} viewBox="0 0 86 62" aria-hidden="true">
      <ellipse cx="38" cy="30" rx="20" ry="13" fill="var(--wx-cloud, #fff)" />
      <ellipse cx="56" cy="32" rx="16" ry="11" fill="var(--wx-cloud-dim, #eef2f7)" />
    </svg>
  );
}
