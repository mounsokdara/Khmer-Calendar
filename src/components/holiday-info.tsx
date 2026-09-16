import { Dialog, DlgBtn } from "./dialog";
import { useStore } from "../lib/store";
import { t } from "../lib/i18n";
import { fromIso } from "../lib/dates";
import {
  gregorianLabel,
  lunarLabel,
  obsSub,
  obsTitle,
  holidayTypeLabel,
  type Observance,
} from "../lib/observances";

const KIND: Record<Observance["kind"], "kindHoliday" | "kindSil" | "kindEvent"> = {
  holiday: "kindHoliday",
  sil: "kindSil",
  event: "kindEvent",
};

export function HolidayInfo({
  open,
  item,
  onClose,
}: {
  open: boolean;
  item: Observance | null;
  onClose: () => void;
}) {
  const lang = useStore((s) => s.lang);
  const d = item?.date ? fromIso(item.date) : null;
  return (
    <Dialog
      open={open}
      title={item ? obsTitle(item, lang) : t(lang, "info")}
      onClose={onClose}
      actions={<DlgBtn onClick={onClose}>{t(lang, "close")}</DlgBtn>}
    >
      {item && d ? (
        <div className="flex flex-col gap-3 text-sm leading-relaxed">
          <p className="text-on-variant">
            {t(lang, KIND[item.kind])}
            {item.holidayType ? ` · ${holidayTypeLabel(item.holidayType, lang)}` : ""}
          </p>
          <p>{gregorianLabel(d, lang)}</p>
          <p>{lunarLabel(item.date, lang)}</p>
          {item.kind === "sil" ? <p className="text-on-variant">{t(lang, "silBlurb")}</p> : null}
          {obsSub(item, lang) ? <p className="text-on-variant">{obsSub(item, lang)}</p> : null}
        </div>
      ) : null}
    </Dialog>
  );
}
