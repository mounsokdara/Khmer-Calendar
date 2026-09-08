import { ZODIAC_EN } from "../lib/chhankitek";
import type { Lang } from "../lib/i18n";

const MAP: Record<string, string> = {
  ជូត: "rat",
  ឆ្លូវ: "ox",
  ខាល: "tiger",
  ថោះ: "rabbit",
  រោង: "dragon",
  ម្សាញ់: "snake",
  មមី: "horse",
  មមែ: "goat",
  វក: "monkey",
  រកា: "rooster",
  ច: "dog",
  កុរ: "pig",
};

export function AnimalArt({ animal, className }: { animal: string; className?: string }) {
  const slug = MAP[animal] ?? "horse";
  const url = `url("/zodiac/svg/${slug}.svg")`;
  return (
    <span
      className={className ? `zodiac-glyph ${className}` : "zodiac-glyph day-animal-art"}
      aria-hidden="true"
      style={{
        WebkitMaskImage: url,
        maskImage: url,
        WebkitMaskRepeat: "no-repeat",
        maskRepeat: "no-repeat",
        WebkitMaskPosition: "center",
        maskPosition: "center",
        WebkitMaskSize: "contain",
        maskSize: "contain",
        backgroundColor: "currentColor",
      }}
    />
  );
}

export function animalLabel(animal: string, lang: Lang) {
  if (lang === "en") return ZODIAC_EN[animal] ?? animal;
  return animal;
}
