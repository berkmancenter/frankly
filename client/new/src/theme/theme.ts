import { alpha, createTheme, type Theme, type ThemeOptions } from '@mui/material/styles';
import { lightScheme, type M3Scheme } from './m3';
import { m3Type } from './typography';

/**
 * Material 3 on MUI.
 *
 * `@mui/material` implements Material 2. There is no first-party M3 component set, so
 * this theme moves MUI toward M3 using what MUI *does* expose: the color roles from the
 * Flutter app's `ColorScheme`, the M3 type scale, M3 shape tokens, M3 state-layer opacities
 * (hover 8 %, focus/press 10 %) and component overrides for the handful of components
 * whose M3 anatomy differs materially (Switch, Tabs, Dialog, Card, Menu, Tooltip, FAB...).
 *
 * `createAppTheme(scheme)` is a pure function of a color scheme, which is what lets a
 * community page nest a second `ThemeProvider` with its own primary/secondary — the
 * equivalent of the `childTheme` that Flutter's `CustomScaffold` applies.
 */
export function createAppTheme(scheme: M3Scheme = lightScheme): Theme {
  const options: ThemeOptions = {
    palette: {
      mode: 'light',
      primary: {
        main: scheme.primary,
        contrastText: scheme.onPrimary,
        light: scheme.primaryFixedDim,
        dark: scheme.primaryContainer,
      },
      secondary: { main: scheme.secondary, contrastText: scheme.onSecondary },
      error: {
        main: scheme.error,
        contrastText: scheme.onError,
        light: scheme.errorContainer,
      },
      background: { default: scheme.surface, paper: scheme.surfaceContainerLowest },
      text: {
        primary: scheme.onSurface,
        secondary: scheme.onSurfaceVariant,
        disabled: alpha(scheme.onSurface, 0.38),
      },
      divider: scheme.outlineVariant,
      action: {
        active: scheme.onSurfaceVariant,
        hover: alpha(scheme.onSurface, 0.08),
        hoverOpacity: 0.08,
        focus: alpha(scheme.onSurface, 0.1),
        focusOpacity: 0.1,
        selected: alpha(scheme.onSurface, 0.12),
        selectedOpacity: 0.12,
        disabled: alpha(scheme.onSurface, 0.38),
        disabledBackground: alpha(scheme.onSurface, 0.12),
        disabledOpacity: 0.38,
      },
      m3: scheme,
    },
    shape: { borderRadius: 12 },
    typography: {
      fontFamily: '"Inter Variable", Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
      ...m3Type,
      // MUI built-ins mapped onto the M3 roles. Flutter's default text style is bodyMedium.
      h1: m3Type.displayLarge,
      h2: m3Type.displayMedium,
      h3: m3Type.displaySmall,
      h4: m3Type.headlineLarge,
      h5: m3Type.headlineMedium,
      h6: m3Type.headlineSmall,
      subtitle1: m3Type.titleMedium,
      subtitle2: m3Type.titleSmall,
      body1: m3Type.bodyMedium,
      body2: m3Type.bodySmall,
      caption: m3Type.bodySmall,
      overline: m3Type.labelSmall,
      button: { ...m3Type.labelLarge, textTransform: 'none' },
    },
    components: {
      MuiCssBaseline: {
        styleOverrides: {
          html: { WebkitTextSizeAdjust: '100%' },
          body: {
            ...m3Type.bodyMedium,
            backgroundColor: scheme.surface,
            color: scheme.onSurface,
          },
          'img, video': { maxWidth: '100%' },
        },
      },

      // Flutter's `Text` is block-level inside a Column; MUI would render the custom M3 variants
      // as inline <span>s (no margins, no line breaks). Map every role to a block element.
      MuiTypography: {
        defaultProps: {
          variantMapping: {
            displayLarge: 'h1',
            displayMedium: 'h1',
            displaySmall: 'h1',
            headlineLarge: 'h2',
            headlineMedium: 'h2',
            headlineSmall: 'h2',
            titleLarge: 'h3',
            titleMedium: 'div',
            titleSmall: 'div',
            labelLarge: 'div',
            labelMedium: 'div',
            labelSmall: 'div',
            bodyLarge: 'p',
            bodyMedium: 'p',
            bodySmall: 'p',
          },
        },
      },

      /* ----- Buttons ------------------------------------------------------ */
      MuiButtonBase: { defaultProps: { disableTouchRipple: false } },
      MuiButton: {
        defaultProps: { disableElevation: true },
        styleOverrides: {
          root: {
            ...m3Type.labelLarge,
            textTransform: 'none',
            borderRadius: 20,
            minHeight: 40,
            padding: '0 24px',
            '&.Mui-disabled': { opacity: 1 },
          },
          text: { padding: '0 12px' },
          contained: ({ ownerState }) => {
            const overlay = (a: number) =>
              `linear-gradient(${alpha('#ffffff', a)}, ${alpha('#ffffff', a)})`;
            return {
              '&:hover': {
                backgroundImage: overlay(0.08),
                backgroundColor:
                  ownerState.color === 'primary' ? scheme.primary : undefined,
                boxShadow: '0 1px 2px rgb(0 0 0 / 0.3), 0 1px 3px 1px rgb(0 0 0 / 0.15)',
              },
              '&:focus-visible, &:active': { backgroundImage: overlay(0.1) },
              '&.Mui-disabled': {
                backgroundColor: alpha(scheme.onSurface, 0.12),
                color: alpha(scheme.onSurface, 0.38),
              },
            };
          },
          outlined: {
            borderColor: scheme.outline,
            '&.Mui-disabled': { borderColor: alpha(scheme.onSurface, 0.12) },
          },
        },
      },
      MuiIconButton: {
        styleOverrides: {
          root: { color: scheme.onSurfaceVariant, '&.Mui-disabled': { opacity: 0.38 } },
        },
      },
      MuiFab: {
        styleOverrides: {
          root: {
            boxShadow: '0 1px 3px rgb(0 0 0 / 0.3), 0 4px 8px 3px rgb(0 0 0 / 0.15)',
            '&:hover': { boxShadow: '0 1px 3px rgb(0 0 0 / 0.3), 0 4px 8px 3px rgb(0 0 0 / 0.15)' },
          },
        },
      },

      /* ----- Surfaces ----------------------------------------------------- */
      MuiPaper: {
        defaultProps: { elevation: 0 },
        styleOverrides: { root: { backgroundImage: 'none' } },
      },
      MuiCard: {
        styleOverrides: {
          root: { borderRadius: 12, backgroundColor: scheme.surfaceContainerLowest },
        },
      },
      MuiDialog: {
        styleOverrides: {
          paper: {
            borderRadius: 20,
            backgroundColor: scheme.surface,
            boxShadow: '0 11px 15px -7px rgb(0 0 0 / 0.2), 0 24px 38px 3px rgb(0 0 0 / 0.14)',
          },
        },
      },
      MuiDialogTitle: { styleOverrides: { root: { ...m3Type.headlineSmall } } },
      MuiDrawer: {
        styleOverrides: { paper: { backgroundColor: scheme.surfaceContainerLowest } },
      },
      MuiMenu: {
        styleOverrides: {
          paper: {
            borderRadius: 4,
            backgroundColor: scheme.surfaceContainer,
            boxShadow: '0 2px 4px -1px rgb(0 0 0 / 0.2), 0 4px 5px 0 rgb(0 0 0 / 0.14), 0 1px 10px 0 rgb(0 0 0 / 0.12)',
          },
        },
      },
      MuiMenuItem: {
        styleOverrides: { root: { ...m3Type.labelLarge, minHeight: 48 } },
      },
      MuiTooltip: {
        defaultProps: { arrow: false },
        styleOverrides: {
          tooltip: {
            ...m3Type.bodySmall,
            backgroundColor: scheme.inverseSurface,
            color: scheme.onInverseSurface,
            borderRadius: 4,
            padding: '4px 8px',
          },
        },
      },
      MuiDivider: { styleOverrides: { root: { borderColor: scheme.outlineVariant } } },
      MuiAlert: {
        styleOverrides: {
          root: { borderRadius: 4, ...m3Type.bodyMedium },
        },
      },
      MuiSnackbarContent: {
        styleOverrides: {
          root: {
            ...m3Type.bodyMedium,
            backgroundColor: scheme.inverseSurface,
            color: scheme.onInverseSurface,
            borderRadius: 4,
          },
        },
      },

      /* ----- Inputs ------------------------------------------------------- */
      MuiTextField: { defaultProps: { variant: 'outlined' } },
      MuiOutlinedInput: {
        styleOverrides: {
          root: {
            borderRadius: 5,
            backgroundColor: 'transparent',
            '& .MuiOutlinedInput-notchedOutline': { borderColor: scheme.outline },
            '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: scheme.onSurface },
            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
              borderColor: scheme.primary,
              borderWidth: 2,
            },
            '&.Mui-error .MuiOutlinedInput-notchedOutline': { borderColor: scheme.error },
          },
          input: { ...m3Type.bodyLarge },
        },
      },
      MuiInputLabel: {
        styleOverrides: {
          root: { color: scheme.onSurfaceVariant, '&.Mui-focused': { color: scheme.primary } },
        },
      },
      MuiFormHelperText: { styleOverrides: { root: { ...m3Type.bodySmall } } },
      MuiCheckbox: {
        defaultProps: { color: 'primary' },
        styleOverrides: { root: { color: scheme.onSurfaceVariant } },
      },
      MuiRadio: {
        defaultProps: { color: 'primary' },
        styleOverrides: { root: { color: scheme.onSurfaceVariant } },
      },
      MuiSwitch: {
        // Material 3 switch: 52x32 track with a 16px (off) / 24px (on) thumb.
        styleOverrides: {
          root: { width: 52, height: 32, padding: 0, overflow: 'visible' },
          switchBase: {
            padding: 8,
            top: 0,
            left: 0,
            transition: 'transform 150ms',
            color: scheme.outline,
            '&.Mui-checked': {
              transform: 'translateX(20px)',
              color: scheme.onPrimary,
              padding: 4,
              '& + .MuiSwitch-track': {
                backgroundColor: scheme.primary,
                borderColor: scheme.primary,
                opacity: 1,
              },
            },
            '&.Mui-disabled + .MuiSwitch-track': { opacity: 0.4 },
          },
          thumb: { width: 16, height: 16, boxShadow: 'none' },
          track: {
            borderRadius: 16,
            backgroundColor: scheme.surfaceContainerHighest,
            border: `2px solid ${scheme.outline}`,
            opacity: 1,
            boxSizing: 'border-box',
          },
        },
      },
      MuiChip: {
        styleOverrides: {
          root: { ...m3Type.labelLarge, borderRadius: 8, height: 32 },
          outlined: { borderColor: scheme.outline },
        },
      },
      MuiLinearProgress: {
        styleOverrides: { root: { borderRadius: 2, height: 4 } },
      },

      /* ----- Navigation --------------------------------------------------- */
      MuiTabs: {
        styleOverrides: {
          root: { minHeight: 48 },
          indicator: { height: 3, borderRadius: '3px 3px 0 0', backgroundColor: scheme.primary },
        },
      },
      MuiTab: {
        styleOverrides: {
          root: {
            ...m3Type.titleSmall,
            textTransform: 'none',
            minHeight: 48,
            color: scheme.onSurfaceVariant,
            '&.Mui-selected': { color: scheme.primary },
          },
        },
      },
      MuiListItemIcon: { styleOverrides: { root: { minWidth: 40, color: scheme.onSurfaceVariant } } },
    },
  };

  return createTheme(options);
}

export const appTheme = createAppTheme(lightScheme);
