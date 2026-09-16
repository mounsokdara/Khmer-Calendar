import { isOsName, OsLogo } from "./os-logo";

export function Icon({
  name,
  filled,
  className,
}: {
  name: string;
  filled?: boolean;
  className?: string;
}) {
  if (isOsName(name)) return <OsLogo name={name} className={className} />;
  const cls = ["ms-icon", filled ? "fill" : "", className].filter(Boolean).join(" ");
  return (
    <span className={cls} aria-hidden="true">
      {name}
    </span>
  );
}
