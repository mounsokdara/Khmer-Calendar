import { createFileRoute } from "@tanstack/react-router";
import { useStore } from "../../lib/store";
import { t } from "../../lib/i18n";
import { LinkRow, SetGroup, SubHead } from "../../components/settings-ui";

export const Route = createFileRoute("/tools/")({ component: ToolsHome });

function ToolsHome() {
  const lang = useStore((s) => s.lang);
  return (
    <div className="more-layout set-page">
      <SubHead title={t(lang, "toolsTitle")} backTo="/more" />
      <SetGroup>
        <LinkRow icon="calculate" title={t(lang, "calcTitle")} subtitle={t(lang, "calcSub")} to="/tools/datecalculator" />
      </SetGroup>
    </div>
  );
}
