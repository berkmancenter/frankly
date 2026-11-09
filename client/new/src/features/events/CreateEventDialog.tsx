import AddIcon from "@mui/icons-material/Add";
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Chip from "@mui/material/Chip";
import FormControlLabel from "@mui/material/FormControlLabel";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useState } from "react";
import { useNavigate } from "react-router";
import { paths } from "@/app/paths";
import type { Template } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { Img } from "@/components/Img";
import {
  combineDateAndTime,
  MonthCalendar,
  TimeInput,
  type TimeValue,
} from "@/components/pickers";
import { useToast } from "@/components/Toast";
import { useClock } from "@/utils/clock";
import { timeZoneAbbreviation } from "@/utils/format";
import { useIsMobile } from "@/utils/useResponsive";
import { useCreateEvent } from "@/queries/events";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";

type StepId = "template" | "visibility" | "date" | "time";

const STEPS: StepId[] = ["template", "visibility", "date", "time"];

/**
 * The multi-step create-event flow. Step order (matching Flutter): Choose Template → Public or
 * private? → Select a day → Select a time → Create Event. All of it is local component state;
 * the only server call is the final `useCreateEvent`.
 */
function CreateEventDialog({ onClose }: { onClose: () => void }) {
  const { community, permissions, templates } = useCommunityScope();
  const clock = useClock();
  const navigate = useNavigate();
  const toast = useToast();
  const isMobile = useIsMobile();
  const createEvent = useCreateEvent();

  const [stepIndex, setStepIndex] = useState(0);
  const step = STEPS[stepIndex]!;

  const [template, setTemplate] = useState<Template | undefined>();
  const [isPublic, setIsPublic] = useState(false);
  const [day, setDay] = useState<Date | null>(null);
  const [time, setTime] = useState<TimeValue>({ hour: 6, minute: 0, pm: true });

  const now = clock.now();
  const scheduled = day ? combineDateAndTime(day, time) : null;
  const inPast = !!scheduled && scheduled.getTime() <= now.getTime();

  const isLast = stepIndex === STEPS.length - 1;
  const canAdvance =
    (step === "template" && !!template) ||
    step === "visibility" ||
    (step === "date" && !!day) ||
    (step === "time" && !!scheduled && !inPast);

  const titles: Record<StepId, string> = {
    template: "Choose Template",
    visibility: "Public or private?",
    date: "Select a day",
    time: "Select a time",
  };

  const submit = async () => {
    if (!template || !scheduled) return;
    try {
      const event = await createEvent.mutateAsync({
        communityId: community.id,
        templateId: template.id,
        scheduledTime: scheduled.toISOString(),
        durationInMinutes: 60,
        eventType: "hosted",
        isPublic,
      });
      onClose();
      navigate(
        paths.community(community.displayId).event(event.templateId, event.id),
      );
    } catch {
      toast.error("Something went wrong creating the event. Please try again.");
    }
  };

  const next = () => (isLast ? submit() : setStepIndex((i) => i + 1));

  return (
    <AppDialog open onClose={onClose} fullscreenOnMobile maxWidth={700}>
      <Box
        sx={{ display: "flex", flexDirection: "column", alignItems: "stretch" }}
      >
        {stepIndex > 0 && (
          <Typography sx={{ fontSize: fontSizes.md, mb: "10px" }}>
            STEP {stepIndex + 1} OF {STEPS.length}
          </Typography>
        )}
        <Typography
          component="h2"
          sx={{
            fontSize: isMobile ? 32 : 40,
            fontWeight: 700,
            lineHeight: 1.1,
            textAlign: "center",
            mb: "20px",
          }}
        >
          {titles[step]}
        </Typography>

        {step === "template" && (
          <TemplateStep
            templates={templates}
            selected={template}
            onSelect={setTemplate}
            canCreateTemplate={permissions.canCreateTemplate}
            // Creating templates is not migrated: this hands off to Flutter.
            onCreateTemplate={() =>
              navigate(paths.community(community.displayId).templates)
            }
          />
        )}
        {step === "visibility" && (
          <VisibilityStep isPublic={isPublic} onChange={setIsPublic} />
        )}
        {step === "date" && (
          <MonthCalendar
            value={day}
            onChange={setDay}
            minDate={now}
            today={now}
          />
        )}
        {step === "time" && (
          <Box>
            <TimeInput value={time} onChange={setTime} />
            <Typography
              sx={{ fontSize: fontSizes.xs, textAlign: "right", mt: "12px" }}
            >
              Time shown in {timeZoneAbbreviation(now)}
            </Typography>
            {inPast && (
              <Typography
                sx={{ fontSize: fontSizes.xs, color: colors.error, mt: "8px" }}
              >
                Please choose a time in the future.
              </Typography>
            )}
          </Box>
        )}

        <Box
          sx={{
            mt: "25px",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          {stepIndex > 0 ? (
            <ButtonBase
              onClick={() => setStepIndex((i) => i - 1)}
              sx={{
                py: "8px",
                pr: "12px",
                borderRadius: 2,
                color: "primary.main",
              }}
            >
              <ChevronLeftIcon sx={{ color: "primary.main" }} />
              <Typography
                sx={{ fontSize: fontSizes.md, ml: "10px", color: "primary.main" }}
              >
                Back
              </Typography>
            </ButtonBase>
          ) : (
            <span />
          )}
          <ActionButton
            text={isLast ? "Create Event" : "Next"}
            disabled={!canAdvance}
            onPress={next}
          />
        </Box>
      </Box>
    </AppDialog>
  );
}

function VisibilityStep({
  isPublic,
  onChange,
}: {
  isPublic: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <RadioGroup
      value={isPublic ? "public" : "private"}
      onChange={(e) => onChange(e.target.value === "public")}
      sx={{ alignSelf: "center", mt: "4px" }}
    >
      <FormControlLabel
        value="public"
        control={<Radio color="primary" />}
        label={
          <Typography sx={{ fontSize: 15, color: "primary.main" }}>
            Allow the community to join
          </Typography>
        }
      />
      <FormControlLabel
        value="private"
        control={<Radio color="primary" />}
        label={
          <Typography sx={{ fontSize: 15, color: "primary.main" }}>
            I'll share this with a private group
          </Typography>
        }
      />
    </RadioGroup>
  );
}

function TemplateStep({
  templates,
  selected,
  onSelect,
  canCreateTemplate,
  onCreateTemplate,
}: {
  templates: Template[];
  selected: Template | undefined;
  onSelect: (t: Template) => void;
  canCreateTemplate: boolean;
  onCreateTemplate: () => void;
}) {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState<string | null>(null);
  const categories = [
    ...new Set(
      templates.map((t) => t.category).filter((c): c is string => !!c),
    ),
  ];
  const visible = templates.filter(
    (t) =>
      (!category || t.category === category) &&
      (!search || t.title.toLowerCase().includes(search.toLowerCase())),
  );

  return (
    <Box>
      <TextField
        fullWidth
        label="Search templates"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        sx={{
          "& .MuiOutlinedInput-root": {
            borderRadius: "10px",
            bgcolor: colors.surfaceContainerLowest,
          },
          my: "6px",
        }}
      />
      {categories.length > 0 && (
        <Box
          sx={{
            display: "flex",
            flexWrap: "wrap",
            gap: "4px 3px",
            mt: "8px",
            mb: "20px",
          }}
        >
          {categories.map((c) => (
            <Chip
              key={c}
              label={c}
              onClick={() => setCategory(category === c ? null : c)}
              sx={{
                bgcolor:
                  category === c ? "primary.main" : colors.surfaceContainer,
                color: category === c ? "primary.contrastText" : colors.onSurface,
                "&:hover": {
                  bgcolor:
                    category === c ? "primary.main" : colors.surfaceContainerHigh,
                },
              }}
            />
          ))}
        </Box>
      )}
      <Box
        sx={{
          display: "flex",
          overflowX: "auto",
          height: 168,
          gap: "20px",
          alignItems: "center",
          py: "4px",
        }}
      >
        {canCreateTemplate && (
          <ButtonBase
            onClick={onCreateTemplate}
            sx={{
              flex: "0 0 156px",
              height: 156,
              borderRadius: "10px",
              boxShadow: "0 1px 4px rgba(0,0,0,.25)",
              flexDirection: "column",
              gap: "6px",
              color: "primary.main",
              bgcolor: colors.surfaceContainerLowest,
            }}
          >
            <AddIcon />
            <Typography
              sx={{
                fontSize: 13,
                fontWeight: 900,
                color: "primary.main",
                px: 1,
              }}
            >
              Create a new template
            </Typography>
          </ButtonBase>
        )}
        {visible.map((t) => {
          const isSelected = selected?.id === t.id;
          return (
            <ButtonBase
              key={t.id}
              onClick={() => onSelect(t)}
              aria-pressed={isSelected}
              sx={{
                flex: "0 0 146px",
                height: 156,
                borderRadius: "10px",
                position: "relative",
                overflow: "hidden",
                bgcolor: colors.surfaceContainerLowest,
                outline: isSelected ? "3px solid" : "1px dashed",
                outlineColor: isSelected ? "primary.main" : colors.outline,
                outlineOffset: 2,
                alignItems: "flex-end",
                justifyContent: "flex-start",
                textAlign: "left",
                "&:hover .tile-overlay": { opacity: 0.9 },
              }}
            >
              <Img
                src={t.image}
                width="100%"
                height="100%"
                sx={{ position: "absolute", inset: 0 }}
              />
              <Box
                className="tile-overlay"
                sx={{
                  position: "absolute",
                  inset: 0,
                  bgcolor: "primary.main",
                  opacity: 0.8,
                  mixBlendMode: "multiply",
                  transition: "opacity .15s",
                }}
              />
              <Box
                aria-hidden
                sx={{
                  position: "absolute",
                  left: 8,
                  top: 10,
                  width: 23,
                  height: 23,
                  borderRadius: "50%",
                  border: "1px solid #fff",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                {isSelected && (
                  <Box
                    sx={{
                      width: 17,
                      height: 17,
                      borderRadius: "50%",
                      bgcolor: "#fff",
                    }}
                  />
                )}
              </Box>
              <Typography
                sx={{
                  position: "relative",
                  px: "20px",
                  py: "15px",
                  fontSize: 14,
                  fontWeight: 900,
                  lineHeight: 1.3,
                  color: "primary.contrastText",
                  display: "-webkit-box",
                  WebkitLineClamp: 4,
                  WebkitBoxOrient: "vertical",
                  overflow: "hidden",
                }}
              >
                {t.title}
              </Typography>
            </ButtonBase>
          );
        })}
        {visible.length === 0 && !canCreateTemplate && (
          <Typography
            sx={{ fontSize: fontSizes.md, color: colors.onPrimaryContainer }}
          >
            No templates found.
          </Typography>
        )}
      </Box>
    </Box>
  );
}

/**
 * Owner of the create-event dialog state. Any component that can start the flow (FAB, bottom
 * nav, empty state) calls this hook and renders `dialog`; the dialog (and its state) exists only
 * while open and is owned by that component — no global dialog store.
 */
export function useCreateEventDialog() {
  const [open, setOpen] = useState(false);
  return {
    open: () => setOpen(true),
    dialog: open ? <CreateEventDialog onClose={() => setOpen(false)} /> : null,
  };
}
