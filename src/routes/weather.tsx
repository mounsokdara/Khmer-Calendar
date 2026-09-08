import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Icon } from "../components/icon";
import { StackBar } from "../components/stack-bar";
import { WxArt } from "../components/wx-art";
import { MdIconBtn, MdBtn } from "../components/md-click";
import { Ripple } from "../components/ripple";
import { useStore } from "../lib/store";
import { t } from "../lib/i18n";
import {
  CITIES,
  cityById,
  fetchWeather,
  readWeatherCache,
  wrapWeatherError,
  wmoOf,
  type WeatherSnap,
  type City,
} from "../lib/weather";

export const Route = createFileRoute("/weather")({ component: WeatherPage });

function WeatherPage() {
  const lang = useStore((s) => s.lang);
  const ids = useStore((s) => s.weatherCities);
  const add = useStore((s) => s.addWeatherCity);
  const remove = useStore((s) => s.removeWeatherCity);
  const [data, setData] = useState<Record<string, WeatherSnap>>(() => readWeatherCache());
  const [err, setErr] = useState<string | null>(null);
  const [offline, setOffline] = useState(typeof navigator !== "undefined" && !navigator.onLine);
  const [picker, setPicker] = useState(false);
  const [detail, setDetail] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const [swipe, setSwipe] = useState<Record<string, number>>({});
  const [tick, setTick] = useState(0);

  useEffect(() => {
    const on = () => setOffline(!navigator.onLine);
    window.addEventListener("online", on);
    window.addEventListener("offline", on);
    return () => {
      window.removeEventListener("online", on);
      window.removeEventListener("offline", on);
    };
  }, []);

  useEffect(() => {
    let dead = false;
    (async () => {
      try {
        let lastErr: unknown = null;
        const next: Record<string, WeatherSnap> = { ...readWeatherCache() };
        for (const id of ids) {
          const c = cityById(id);
          if (!c) continue;
          try {
            next[id] = await fetchWeather(c);
          } catch (e) {
            lastErr = e;
          }
          await new Promise((r) => setTimeout(r, 400));
          if (dead) return;
        }
        if (!dead) {
          setData(next);
          const any = ids.some((id) => next[id]);
          setErr(any ? null : lastErr ? wrapWeatherError(lastErr).label : null);
          if (!offline && tick > 0 && any) setToast(t(lang, "updated"));
        }
      } catch (e) {
        if (!dead) setErr(wrapWeatherError(e).label);
      }
    })();
    return () => {
      dead = true;
    };
  }, [ids.join(","), offline, tick]);

  const cachedAny = ids.some((id) => data[id]);
  if (offline && !cachedAny) {
    return (
      <section className="tab-page">
        <div className="wx-page">
          <div className="wx-offline">
            <Icon name="cloud_off" className="wx-offline-mark" />
            <h2>{t(lang, "wxOfflineTitle")}</h2>
            <p>{t(lang, "wxOfflineBody")}</p>
            <MdBtn tag="md-outlined-button" wide onClick={() => setTick((n) => n + 1)}>
              {t(lang, "wxRetry")}
            </MdBtn>
          </div>
        </div>
      </section>
    );
  }

  const open = detail ? cityById(detail) : null;
  const snap = detail ? data[detail] : null;

  return (
    <section className="tab-page">
      <div className="wx-page">
        <header className="wx-head">
          <h1>{t(lang, "weather")}</h1>
          <MdIconBtn className="wx-add" onClick={() => setPicker(true)} ariaLabel={t(lang, "addCity")}>
            <Icon name="add_home" />
          </MdIconBtn>
        </header>
        <div className="wx-list">
          {err && !cachedAny ? <p className="wx-error">{t(lang, "weatherError")}</p> : null}
          {ids.length === 0 ? (
            <div className="wx-empty">
              <p>{t(lang, "noCity")}</p>
              <MdBtn tag="md-outlined-button" wide onClick={() => setPicker(true)}>
                {t(lang, "addCity")}
              </MdBtn>
            </div>
          ) : (
            ids.map((id) => {
              const c = cityById(id);
              if (!c) return null;
              const s = data[id];
              const w = s ? wmoOf(s.code) : null;
              const x = swipe[id] ?? 0;
              return (
                <div key={id} className="wx-swipe">
                  <button type="button" className="wx-swipe-delete" onClick={() => remove(id)}>
                    <Icon name="delete" />
                    {t(lang, "delete")}
                  </button>
                  <button
                    type="button"
                    className={`wx-card ${Math.abs(x) > 8 ? "is-dragging" : ""}`}
                    style={{ transform: `translateX(${x}px)` }}
                    onPointerDown={(e) => {
                      const start = e.clientX;
                      const move = (ev: PointerEvent) => {
                        setSwipe((p) => ({ ...p, [id]: Math.min(0, ev.clientX - start) }));
                      };
                      const up = (ev: PointerEvent) => {
                        document.removeEventListener("pointermove", move);
                        document.removeEventListener("pointerup", up);
                        const dx = ev.clientX - start;
                        if (dx < -88) remove(id);
                        setSwipe((p) => ({ ...p, [id]: 0 }));
                      };
                      document.addEventListener("pointermove", move);
                      document.addEventListener("pointerup", up);
                    }}
                    onClick={() => {
                      if (Math.abs(x) < 8) setDetail(id);
                    }}
                  >
                    <img src={c.photo} alt="" className="wx-card-photo" draggable={false} />
                    <div className="wx-card-shade" />
                    <div className="wx-card-body">
                      <div className="wx-card-left">
                        <Icon name="location_on" className="wx-mini-icon" filled />
                        <div className="wx-card-temp">{s ? `${s.temp}°` : "—"}</div>
                        <div className="wx-card-name">{lang === "en" ? c.nameEn : c.name}</div>
                        <div className="wx-card-desc">{w ? (lang === "en" ? w.en : w.km) : ""}</div>
                      </div>
                      <div className="wx-card-right">
                        {w ? <WxArt kind={w.kind} className="wx-art" /> : null}
                        {s ? (
                          <div className="wx-card-hl">
                            H {s.high}°/{s.low}°
                          </div>
                        ) : null}
                      </div>
                    </div>
                  </button>
                </div>
              );
            })
          )}
        </div>
      </div>
      {picker ? (
        <div className="wx-overlay sheet-page">
          <header className="wx-picker-head">
            <MdIconBtn className="icon-btn" onClick={() => setPicker(false)} ariaLabel={t(lang, "back")}>
              <Icon name="arrow_back" />
            </MdIconBtn>
            <h1>{t(lang, "findCity")}</h1>
          </header>
          <div className="wx-picker-list">
            {CITIES.map((c) => (
              <button
                key={c.id}
                type="button"
                className="wx-picker-row has-ripple"
                onClick={() => {
                  add(c.id);
                  setPicker(false);
                }}
              >
                <Ripple />
                {lang === "en" ? c.nameEn : c.name}
              </button>
            ))}
          </div>
        </div>
      ) : null}
      {open && snap ? <CityDetail city={open} snap={snap} lang={lang} onClose={() => setDetail(null)} /> : null}
      <StackBar open={!!toast} message={toast ?? ""} onDismiss={() => setToast(null)} />
    </section>
  );
}

function CityDetail({
  city,
  snap,
  lang,
  onClose,
}: {
  city: City;
  snap: WeatherSnap;
  lang: "km" | "en";
  onClose: () => void;
}) {
  const w = wmoOf(snap.code);
  const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const daysKm = ["អាទិត្យ", "ចន្ទ", "អង្គារ", "ពុធ", "ព្រហ.", "សុក្រ", "សៅរ៍"];
  return (
    <div className={`sheet-page wx-detail wx-kind-${w.kind}`}>
      <img src={city.photo} alt="" className="wx-detail-photo" />
      <div className="wx-detail-shade" />
      <header className="wx-detail-head">
        <MdIconBtn className="wx-back" onClick={onClose} ariaLabel={t(lang, "back")}>
          <Icon name="arrow_back" />
        </MdIconBtn>
      </header>
      <div className="wx-detail-hero">
        <div className="wx-detail-copy">
          <h1 className="wx-detail-city">{lang === "en" ? city.nameEn : city.name}</h1>
          <p className="wx-detail-temp">{snap.temp}°</p>
        </div>
        <WxArt kind={w.kind} className="wx-detail-art" />
      </div>
      <p className="wx-detail-desc">{lang === "en" ? w.en : w.km}</p>
      <p className="wx-detail-feel">
        {t(lang, "feels")} {snap.apparent}°
      </p>
      <div className="wx-detail-scroll">
        <section className="wx-panel">
          <h2>{t(lang, "hourly")}</h2>
          <div className="wx-hours">
            {snap.hourly.map((h) => {
              const hw = wmoOf(h.code);
              return (
                <div key={h.time} className="wx-hour">
                  <span>{h.time.slice(11, 16)}</span>
                  <WxArt kind={hw.kind} className="wx-hour-art" />
                  <strong>{h.temp}°</strong>
                </div>
              );
            })}
          </div>
        </section>
        <section className="wx-panel">
          <h2>{t(lang, "weekly")}</h2>
          <div className="wx-days">
            {snap.daily.map((d) => {
              const dt = new Date(`${d.date}T12:00:00`);
              const name = lang === "en" ? days[dt.getDay()] : daysKm[dt.getDay()];
              return (
                <div key={d.date} className="wx-day">
                  <span className="wx-day-name">{name}</span>
                  <WxArt kind={wmoOf(d.code).kind} className="wx-hour-art" />
                  <span className="wx-day-hl">
                    {d.high}°<em>{d.low}°</em>
                  </span>
                </div>
              );
            })}
          </div>
        </section>
        <div className="wx-stats">
          <div className="wx-stat">
            <Icon name="wb_sunny" />
            <p>{t(lang, "uv")}</p>
            <strong>{snap.uv}</strong>
          </div>
          <div className="wx-stat">
            <Icon name="water_drop" />
            <p>{t(lang, "humidity")}</p>
            <strong>{snap.humidity}%</strong>
          </div>
          <div className="wx-stat">
            <Icon name="air" />
            <p>{t(lang, "wind")}</p>
            <strong>
              {snap.wind} {t(lang, "kmh")}
            </strong>
          </div>
          <div className="wx-stat">
            <Icon name="device_thermostat" />
            <p>{t(lang, "feels")}</p>
            <strong>{snap.apparent}°</strong>
          </div>
        </div>
      </div>
    </div>
  );
}
