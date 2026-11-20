import CheckIcon from "@mui/icons-material/Check";
import WaterDropIcon from "@mui/icons-material/WaterDrop";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Tab from "@mui/material/Tab";
import Tabs from "@mui/material/Tabs";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import { colors } from "@/theme/tokens";
import {
  PRESET_COLOR_THEMES,
  isAccentDarkEnough,
  isBackgroundLightEnough,
  isColorValid,
} from "@/utils/communityTheme";

const PRESETS = "presets";
const CUSTOM = "custom";
type Mode = typeof PRESETS | typeof CUSTOM;

export interface ThemeColors {
  /** `RRGGBB`, or empty while the community has none. */
  light: string;
  dark: string;
}

const same = (a: string, b: string) => a.toUpperCase() === b.toUpperCase();
const presetIndex = ({ light, dark }: ThemeColors) =>
  PRESET_COLOR_THEMES.findIndex(
    (preset) => same(preset.light, light) && same(preset.dark, dark),
  );

// Choosing a community's colors: a preset, or a background and an accent of the admin's own that
// stay readable. A mock-up shows how the pair looks.
export function ThemeColorSection({
  value,
  onChange,
}: {
  value: ThemeColors;
  onChange: (value: ThemeColors) => void;
}) {
  const { t } = useLingui();
  const unset = !value.light && !value.dark;
  const [mode, setMode] = useState<Mode>(
    unset || presetIndex(value) >= 0 ? PRESETS : CUSTOM,
  );

  return (
    <Box>
      <Typography sx={{ fontWeight: 900, mb: "30px" }}>
        {t({ id: "theme", message: "Theme" })}
      </Typography>
      <Tabs
        value={mode}
        onChange={(_, next: Mode) => setMode(next)}
        variant="fullWidth"
      >
        <Tab value={PRESETS} label={t({ id: "presets", message: "Presets" })} />
        <Tab value={CUSTOM} label={t({ id: "custom", message: "Custom" })} />
      </Tabs>
      {mode === PRESETS ? (
        <Presets value={value} onChange={onChange} />
      ) : (
        <Custom value={value} onChange={onChange} />
      )}
    </Box>
  );
}

function Presets({
  value,
  onChange,
}: {
  value: ThemeColors;
  onChange: (value: ThemeColors) => void;
}) {
  const selected = unsetAsFirst(value);
  return (
    <Box
      sx={{ display: "flex", flexWrap: "wrap", gap: "30px 10px", pt: "20px" }}
    >
      {PRESET_COLOR_THEMES.map((preset, index) => (
        <ButtonBase
          key={preset.light + preset.dark}
          aria-label={`#${preset.light} #${preset.dark}`}
          aria-pressed={selected === index}
          onClick={() => onChange(preset)}
          sx={{
            width: 56,
            height: 56,
            borderRadius: "50%",
            bgcolor: `#${preset.light}`,
            boxShadow: 3,
          }}
        >
          <Box
            sx={{
              width: 30,
              height: 30,
              borderRadius: "50%",
              bgcolor: `#${preset.dark}`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: colors.onPrimaryContainer,
            }}
          >
            {selected === index && <CheckIcon />}
          </Box>
        </ButtonBase>
      ))}
    </Box>
  );
}

// With no colors yet the community looks like the first preset.
const unsetAsFirst = (value: ThemeColors) =>
  !value.light && !value.dark ? 0 : presetIndex(value);

function Custom({
  value,
  onChange,
}: {
  value: ThemeColors;
  onChange: (value: ThemeColors) => void;
}) {
  const { t } = useLingui();
  return (
    <Box sx={{ pt: "20px", maxWidth: 250 }}>
      <Typography sx={{ pb: "20px", fontWeight: 500 }}>
        {t({
          id: "chooseABackgroundAndAccentColor",
          message:
            "Choose a light colored background and a dark accent color that provide enough contrast so that text is readable by a wide range of users including those with moderately low vision. We'll check its readability.",
        })}
      </Typography>
      <ColorField
        label={t({ id: "backgroundColor", message: "Background Color" })}
        value={value.light}
        onChange={(light) => onChange({ ...value, light })}
        problem={
          isColorValid(value.light) && !isBackgroundLightEnough(value.light)
            ? t({
                id: "useLighterBackgroundColor",
                message: "Use a lighter background color.",
              })
            : undefined
        }
      />
      <ColorField
        label={t({ id: "accentColor", message: "Accent Color" })}
        value={value.dark}
        onChange={(dark) => onChange({ ...value, dark })}
        problem={
          isColorValid(value.dark) && !isAccentDarkEnough(value.dark)
            ? t({
                id: "useDarkerAccentColor",
                message: "Use a darker accent color.",
              })
            : undefined
        }
      />
      <Preview value={value} />
    </Box>
  );
}

function ColorField({
  label,
  value,
  onChange,
  problem,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  problem?: string;
}) {
  const { t } = useLingui();
  const malformed = value !== "" && !isColorValid(value);
  return (
    <Box
      sx={{ display: "flex", alignItems: "flex-start", gap: "8px", mb: "10px" }}
    >
      <Box
        component="label"
        sx={{
          position: "relative",
          pt: "20px",
          cursor: "pointer",
          color: isColorValid(value) ? `#${value}` : colors.outline,
        }}
      >
        <WaterDropIcon />
        <Box
          component="input"
          type="color"
          aria-label={label}
          value={isColorValid(value) ? `#${value.toLowerCase()}` : "#ffffff"}
          onChange={(event) =>
            onChange(event.target.value.slice(1).toUpperCase())
          }
          sx={{
            position: "absolute",
            inset: 0,
            opacity: 0,
            width: "100%",
            height: "100%",
            cursor: "pointer",
          }}
        />
      </Box>
      <TextField
        variant="standard"
        label={label}
        value={value}
        onChange={(event) =>
          onChange(event.target.value.replace(/[^0-9a-fA-F]/g, "").slice(0, 6))
        }
        error={malformed || !!problem}
        helperText={
          malformed
            ? t({ id: "mustBeValidHexColor", message: "Must be HEX format" })
            : problem
        }
        slotProps={{
          input: {
            startAdornment: (
              <Box component="span" sx={{ mr: "2px" }}>
                #
              </Box>
            ),
          },
          htmlInput: { maxLength: 6 },
        }}
        fullWidth
      />
    </Box>
  );
}

// A mock-up of a community page in the chosen colors.
function Preview({ value }: { value: ThemeColors }) {
  return (
    <Box
      aria-hidden
      sx={{
        mt: "10px",
        width: 152,
        height: 100,
        borderRadius: "10px",
        bgcolor: isColorValid(value.light) ? `#${value.light}` : colors.surface,
        display: "flex",
        alignItems: "center",
        gap: "7px",
        px: "18px",
      }}
    >
      <Box
        sx={{
          width: 58,
          height: 58,
          borderRadius: "10px",
          bgcolor: isColorValid(value.dark) ? `#${value.dark}` : colors.primary,
        }}
      />
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          height: 58,
        }}
      >
        {[0, 1, 2].map((bar) => (
          <Box
            key={bar}
            sx={{
              width: 50,
              height: 16,
              borderRadius: "10px",
              bgcolor: colors.surfaceContainerLowest,
            }}
          />
        ))}
      </Box>
    </Box>
  );
}
