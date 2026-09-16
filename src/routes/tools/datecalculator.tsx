import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { SubHead } from "../../components/settings-ui";
import { addDays, fromIso, isoOf, todayIso } from "../../lib/dates";
import { lunarOf } from "../../lib/chhankitek";

export const Route = createFileRoute("/tools/datecalculator")({ component: CalcPage });

function CalcPage() {
  const lang = useStore((s) => s.lang);
  const [from, setFrom] = useState(todayIso());
  const [to, setTo] = useState(todayIso());
  const [shift, setShift] = useState("7");
  const dur = useMemo(() => {
    const a = fromIso(from);
    const b = fromIso(to);
    const days = Math.round((b.getTime() - a.getTime()) / 86400000);
    const years = Math.floor(Math.abs(days) / 365);
    const months = Math.floor((Math.abs(days) % 365) / 30);
    const rest = Math.abs(days) - years * 365 - months * 30;
    return { days, years, months, rest };
  }, [from, to]);
  const lunarFrom = lunarOf(fromIso(from));
  const lunarTo = lunarOf(fromIso(to));
  const shifted = isoOf(addDays(fromIso(from), Number(shift) || 0));
  const shiftedLunar = lunarOf(fromIso(shifted));

  return (
    <div className="more-layout calc-page">
      <SubHead title={t(lang, "calcTitle")} backTo="/tools" />
      <p className="sub-lead">{t(lang, "calcSub")}</p>
      <div className="calc-tool">
        <label className="calc-field">
          <span>{t(lang, "calcFrom")}</span>
          <input type="date" value={from} onChange={(e) => setFrom(e.target.value)} />
        </label>
        <label className="calc-field">
          <span>{t(lang, "calcTo")}</span>
          <input type="date" value={to} onChange={(e) => setTo(e.target.value)} />
        </label>
        <div className="calc-card">
          <p className="calc-kicker">{t(lang, "calcDuration")}</p>
          <p className="calc-hero">
            {dur.years} {t(lang, "calcYears")} · {dur.months} {t(lang, "calcMonths")} · {dur.rest} {t(lang, "calcDays")}
          </p>
          <p className="calc-sub">
            {dur.days} {t(lang, "calcTotalDays")}
            {dur.days < 0 ? ` · ${t(lang, "calcPast")}` : ""}
          </p>
        </div>
        <div className="calc-card">
          <p className="calc-kicker">{t(lang, "calcFrom")}</p>
          <p className="calc-line">{lunarFrom.lunarDateText}</p>
          <p className="calc-sub">{lunarFrom.gregorianDateText}</p>
        </div>
        <div className="calc-card">
          <p className="calc-kicker">{t(lang, "calcTo")}</p>
          <p className="calc-line">{lunarTo.lunarDateText}</p>
          <p className="calc-sub">{lunarTo.gregorianDateText}</p>
        </div>
        <div className="calc-shift">
          <p className="calc-kicker">{t(lang, "calcAdd")}</p>
          <div className="calc-shift-row">
            {["7", "15", "30"].map((n) => (
              <button
                key={n}
                type="button"
                className={shift === n ? "calc-chip is-on" : "calc-chip"}
                onClick={() => setShift(n)}
              >
                +{n}
              </button>
            ))}
            <input
              className="calc-shift-input"
              type="number"
              inputMode="numeric"
              value={shift}
              onChange={(e) => setShift(e.target.value)}
            />
          </div>
          <p className="calc-line">{shiftedLunar.lunarDateText}</p>
          <p className="calc-sub">{shifted}</p>
        </div>
      </div>
    </div>
  );
}
