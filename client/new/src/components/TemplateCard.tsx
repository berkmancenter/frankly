import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { Link } from "react-router";
import type { Template } from "@/api/types";
import { colors } from "@/theme/tokens";
import { Img } from "./Img";

// A 160px square: the template's picture under a primary-color tint, with its title bottom left.
export function TemplateCard({ template, to }: { template: Template; to: string }) {
  return (
    <ButtonBase
      component={Link}
      to={to}
      sx={{
        position: "relative",
        width: 160,
        height: 160,
        overflow: "hidden",
        bgcolor: colors.surfaceContainer,
        boxShadow: "1px 1px 4px rgba(0, 0, 0, 0.25)",
        alignItems: "flex-end",
        justifyContent: "flex-start",
        textAlign: "left",
      }}
    >
      <Img src={template.image} width="100%" height="100%" sx={{ position: "absolute", inset: 0 }} />
      <Box
        aria-hidden
        sx={{ position: "absolute", inset: 0, bgcolor: "primary.main", mixBlendMode: "multiply" }}
      />
      <Typography
        sx={{
          position: "relative",
          px: "20px",
          py: "15px",
          fontSize: 18,
          lineHeight: 1.3,
          fontWeight: 700,
          color: colors.onPrimary,
          display: "-webkit-box",
          WebkitLineClamp: 4,
          WebkitBoxOrient: "vertical",
          overflow: "hidden",
        }}
      >
        {template.title}
      </Typography>
    </ButtonBase>
  );
}
