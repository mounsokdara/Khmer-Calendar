export type City = {
  id: string;
  name: string;
  nameEn: string;
  latitude: number;
  longitude: number;
  photo: string;
};

export type WeatherSnap = {
  temp: number;
  high: number;
  low: number;
  code: number;
  humidity: number;
  wind: number;
  uv: number;
  apparent: number;
  hourly: { time: string; temp: number; code: number }[];
  daily: { date: string; high: number; low: number; code: number }[];
  cachedAt: string;
};

export type WxKind = "clear" | "cloudy" | "rain" | "storm";

export const CITIES: City[] = [
  { id: "phnom-penh", name: "ភ្នំពេញ", nameEn: "Phnom Penh", latitude: 11.5564, longitude: 104.9282, photo: "/weather/phnom-penh.jpg" },
  { id: "banteay-meanchey", name: "បន្ទាយមានជ័យ", nameEn: "Banteay Meanchey", latitude: 13.5859, longitude: 102.9737, photo: "/weather/banteay.jpg" },
  { id: "battambang", name: "បាត់ដំបង", nameEn: "Battambang", latitude: 13.0957, longitude: 103.2022, photo: "/weather/battambang.jpg" },
  { id: "kampong-cham", name: "កំពង់ចាម", nameEn: "Kampong Cham", latitude: 11.9934, longitude: 105.4635, photo: "/weather/kampong-cham.jpg" },
  { id: "kampong-chhnang", name: "កំពង់ឆ្នាំង", nameEn: "Kampong Chhnang", latitude: 12.25, longitude: 104.6667, photo: "/weather/kampot.jpg" },
  { id: "kampong-speu", name: "កំពង់ស្ពឺ", nameEn: "Kampong Speu", latitude: 11.4533, longitude: 104.519, photo: "/weather/kampot.jpg" },
  { id: "kampong-thom", name: "កំពង់ធំ", nameEn: "Kampong Thom", latitude: 12.7111, longitude: 104.8889, photo: "/weather/banteay.jpg" },
  { id: "kampot", name: "កំពត", nameEn: "Kampot", latitude: 10.6104, longitude: 104.181, photo: "/weather/kampot-river.jpg" },
  { id: "kandal", name: "កណ្ដាល", nameEn: "Kandal", latitude: 11.4833, longitude: 104.95, photo: "/weather/phnom-penh-alt.jpg" },
  { id: "koh-kong", name: "កោះកុង", nameEn: "Koh Kong", latitude: 11.6153, longitude: 102.9839, photo: "/weather/sihanoukville.jpg" },
  { id: "kratie", name: "ក្រចេះ", nameEn: "Kratie", latitude: 12.4881, longitude: 106.0188, photo: "/weather/kratie.jpg" },
  { id: "mondulkiri", name: "មណ្ឌលគិរី", nameEn: "Mondulkiri", latitude: 12.4558, longitude: 107.1906, photo: "/weather/mondulkiri.jpg" },
  { id: "pailin", name: "ប៉ៃលិន", nameEn: "Pailin", latitude: 12.8489, longitude: 102.6093, photo: "/weather/battambang.jpg" },
  { id: "preah-vihear", name: "ព្រះវិហារ", nameEn: "Preah Vihear", latitude: 13.807, longitude: 104.978, photo: "/weather/preah-vihear.jpg" },
  { id: "prey-veng", name: "ព្រៃវែង", nameEn: "Prey Veng", latitude: 11.485, longitude: 105.325, photo: "/weather/kampong-cham.jpg" },
  { id: "pursat", name: "ពោធិ៍សាត់", nameEn: "Pursat", latitude: 12.5388, longitude: 103.9192, photo: "/weather/kampot.jpg" },
  { id: "ratanakiri", name: "រតនគិរី", nameEn: "Ratanakiri", latitude: 13.7395, longitude: 106.9873, photo: "/weather/mondulkiri.jpg" },
  { id: "siem-reap", name: "សៀមរាប", nameEn: "Siem Reap", latitude: 13.3633, longitude: 103.8564, photo: "/weather/siem-reap.jpg" },
  { id: "sihanoukville", name: "ព្រះសីហនុ", nameEn: "Sihanoukville", latitude: 10.6271, longitude: 103.5222, photo: "/weather/sihanoukville.jpg" },
  { id: "stung-treng", name: "ស្ទឹងត្រែង", nameEn: "Stung Treng", latitude: 13.5259, longitude: 105.9683, photo: "/weather/kratie.jpg" },
  { id: "svay-rieng", name: "ស្វាយរៀង", nameEn: "Svay Rieng", latitude: 11.0879, longitude: 105.7993, photo: "/weather/kampong-cham.jpg" },
  { id: "takeo", name: "តាកែវ", nameEn: "Takeo", latitude: 10.9908, longitude: 104.785, photo: "/weather/kampot-river.jpg" },
  { id: "oddar-meanchey", name: "ឧត្តរមានជ័យ", nameEn: "Oddar Meanchey", latitude: 14.1817, longitude: 103.5176, photo: "/weather/banteay.jpg" },
  { id: "kep", name: "កែប", nameEn: "Kep", latitude: 10.4826, longitude: 104.3167, photo: "/weather/sihanoukville.jpg" },
  { id: "tboung-khmum", name: "ត្បូងឃ្មុំ", nameEn: "Tboung Khmum", latitude: 11.911, longitude: 105.658, photo: "/weather/kampong-cham.jpg" },
];

export function cityById(id: string) {
  return CITIES.find((c) => c.id === id);
}

export function nearestCity(lat: number, lon: number) {
  let best = CITIES[0];
  let dist = Infinity;
  for (const c of CITIES) {
    const d = (c.latitude - lat) ** 2 + (c.longitude - lon) ** 2;
    if (d < dist) {
      dist = d;
      best = c;
    }
  }
  return best;
}

export class WeatherHttpError extends Error {
  httpType: string;
  constructor(type: string, message?: string) {
    super(message ?? `Http ${type}`);
    this.name = "WeatherHttpError";
    this.httpType = type;
  }
  get label() {
    return `Http ${this.httpType}`;
  }
}

export function wrapWeatherError(e: unknown): WeatherHttpError {
  if (e instanceof WeatherHttpError) return e;
  if (typeof navigator !== "undefined" && !navigator.onLine) return new WeatherHttpError("Offline");
  const status = (e as { status?: number } | null)?.status;
  return typeof status === "number" ? new WeatherHttpError(String(status)) : new WeatherHttpError("Failed");
}

const WMO: { max: number; en: string; km: string; kind: WxKind }[] = [
  { max: 0, en: "clear sky", km: "ថ្ងៃថ្លា", kind: "clear" },
  { max: 1, en: "mainly clear", km: "ស្ទើរតែថ្លា", kind: "clear" },
  { max: 2, en: "partly cloudy", km: "មានពពកបន្តិច", kind: "cloudy" },
  { max: 3, en: "overcast clouds", km: "ពពកអស់មេឃ", kind: "cloudy" },
  { max: 48, en: "fog", km: "អ័ព្ទ", kind: "cloudy" },
  { max: 57, en: "drizzle", km: "ភ្លៀងសើម", kind: "rain" },
  { max: 67, en: "rain", km: "ភ្លៀង", kind: "rain" },
  { max: 77, en: "snow", km: "ព្រិល", kind: "rain" },
  { max: 82, en: "rain showers", km: "ភ្លៀងផ្កាឈូក", kind: "rain" },
  { max: 86, en: "snow showers", km: "ព្រិល", kind: "rain" },
  { max: 99, en: "thunderstorm", km: "ព្យុះផ្គររន្ទះ", kind: "storm" },
];

export function wmoOf(code: number) {
  return WMO.find((w) => code <= w.max) ?? WMO[WMO.length - 1];
}

const CACHE_KEY = "khmer-wx-v1";

export function readWeatherCache(): Record<string, WeatherSnap> {
  if (typeof localStorage === "undefined") return {};
  try {
    return JSON.parse(localStorage.getItem(CACHE_KEY) || "{}") as Record<string, WeatherSnap>;
  } catch {
    return {};
  }
}

export function writeWeatherCache(data: Record<string, WeatherSnap>) {
  if (typeof localStorage === "undefined") return;
  try {
    localStorage.setItem(CACHE_KEY, JSON.stringify(data));
  } catch {
    /* quota */
  }
}

export async function fetchWeather(city: City): Promise<WeatherSnap> {
  const cached = readWeatherCache()[city.id];
  if (typeof navigator !== "undefined" && !navigator.onLine) {
    if (cached) return cached;
    throw new WeatherHttpError("Offline");
  }
  const url =
    `https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}` +
    `&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m,apparent_temperature,uv_index` +
    `&hourly=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=Asia%2FPhnom_Penh`;
  try {
    const res = await fetch(url);
    if (!res.ok) {
      if (cached) return cached;
      throw new WeatherHttpError(String(res.status));
    }
    const j = await res.json();
    const hourly = (j.hourly?.time ?? []).slice(0, 12).map((time: string, i: number) => ({
      time,
      temp: Math.round(j.hourly.temperature_2m[i]),
      code: j.hourly.weather_code[i] as number,
    }));
    const daily = (j.daily?.time ?? []).slice(0, 7).map((date: string, i: number) => ({
      date,
      high: Math.round(j.daily.temperature_2m_max[i]),
      low: Math.round(j.daily.temperature_2m_min[i]),
      code: j.daily.weather_code[i] as number,
    }));
    const snap: WeatherSnap = {
      temp: Math.round(j.current.temperature_2m),
      high: daily[0]?.high ?? Math.round(j.current.temperature_2m),
      low: daily[0]?.low ?? Math.round(j.current.temperature_2m),
      code: j.current.weather_code,
      humidity: Math.round(j.current.relative_humidity_2m),
      wind: Math.round(j.current.wind_speed_10m),
      uv: Math.round(j.current.uv_index ?? 0),
      apparent: Math.round(j.current.apparent_temperature),
      hourly,
      daily,
      cachedAt: new Date().toISOString(),
    };
    const cache = readWeatherCache();
    cache[city.id] = snap;
    writeWeatherCache(cache);
    return snap;
  } catch (e) {
    if (cached) return cached;
    throw e instanceof WeatherHttpError ? e : new WeatherHttpError("Failed");
  }
}
