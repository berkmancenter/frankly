import eslint from "@eslint/js";
import type { Rule } from "eslint";
import { defineConfig } from "eslint/config";
import pluginLingui from "eslint-plugin-lingui";
import tseslint from "typescript-eslint";
import {
  COLOR_KEYWORDS,
  COLOR_PROPS,
  THEME_COLOR_PATHS,
} from "./client/new/src/theme/colorPaths.ts";

// The allowed values and restricted properties come from the same lists `sx()` is typed with.
const escape = (value: string) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const THEME_COLOR_PATH = `(?:${THEME_COLOR_PATHS.map(escape).join("|")})`;
const RAW_COLOR = `(?:${COLOR_KEYWORDS.join("|")}|#[0-9a-fA-F]+|rgba?\\(.*\\))`;
const NOT_A_COLOR = `^(?!(?:${THEME_COLOR_PATH}|${RAW_COLOR})$)`;

const COLOR_KEYS = `/^(${COLOR_PROPS.join("|")})$/`;
const colorLiteral = (parent: string) =>
  `Property[key.name=${COLOR_KEYS}]${parent} > Literal[value=/${NOT_A_COLOR}/]`;

// `no-restricted-syntax` has one severity for all its selectors, so these warnings are a small
// local rule (the color rule below stays an error). The sizes mirror `typography` in theme.ts:
// body1 is fontSizes.sm (the default) and body2 is fontSizes.xs.
const typographySize = (variantGuard: string, size: string, token: string) =>
  [
    'JSXOpeningElement[name.name="Typography"]',
    variantGuard,
    ' > JSXAttribute[name.name="sx"] > JSXExpressionContainer > ObjectExpression',
    ' > Property[key.name="fontSize"]',
    `:matches([value.type="Literal"][value.value=${size}], [value.object.name="fontSizes"][value.property.name="${token}"])`,
  ].join("");

const NO_VARIANT = ':not(:has(> JSXAttribute[name.name="variant"]))';
const NOT_OTHER_VARIANT =
  ':not(:has(> JSXAttribute[name.name="variant"][value.value!="body1"]))';

// Rule to catch redundant default font sizes in MUI Typography components
const redundantDefaultFontSize: Rule.RuleModule = {
  meta: { type: "suggestion", schema: [] },
  create: (context) => ({
    [typographySize(NOT_OTHER_VARIANT, "14", "sm")](node: Rule.Node) {
      context.report({
        node,
        message:
          "Redundant: `<Typography>` is body1 by default, which the theme already sets to fontSizes.sm (14px).",
      });
    },
    [typographySize(NO_VARIANT, "12", "xs")](node: Rule.Node) {
      context.report({
        node,
        message:
          'Use `variant="body2"`, which the theme sets to fontSizes.xs (12px), instead of overriding the size.',
      });
    },
  }),
};

export default defineConfig(
  { ignores: ["dist", "node_modules", "src/locales/**/generated*"] },
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ["./client/new/src/**/*.{ts,tsx}"],
    // Type information lets `lingui/no-unlocalized-strings` (`useTsTypes`) skip string literals
    // that are members of a union type, such as the "nonmember" membership status.
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: "/client/new",
      },
    },
    plugins: {
      frankly: {
        rules: { "redundant-default-font-size": redundantDefaultFontSize },
      },
      // eslint-plugin-lingui's rule types predate the installed `eslint` version's Plugin type.
      lingui: pluginLingui as unknown as {
        rules: Record<string, Rule.RuleModule>;
      },
    },
    rules: {
      "frankly/redundant-default-font-size": "warn",
      "lingui/no-unlocalized-strings": [
        "warn",
        {
          useTsTypes: true,
          ignore: [
            "^[A-Z0-9_-]+$",
            // All route path segments
            "^/[a-z0-9/_-]*$",
            // URLs and image file names
            "^(https?:|mailto:)",
            "\\.(png|svg|jpe?g|gif|webp)$",
          ],
          ignoreNames: [
            "aria-labelledby",
            "id",
            "type",
            "contentAlign",
            "className",
            "styleName",
            "src",
            "data-testid",
            // Constants named in SCREAMING_CASE hold codes and identifiers, not copy.
            { regex: { pattern: "^[A-Z][A-Z0-9_]*$" } },
            // `this.name` in error classes, and the `name` attribute of form fields.
            "name",
            // MUI `sx` shorthand / CSS property names and JSX layout props — values here are
            // CSS keywords or theme palette paths, never UI copy a translator would touch.
            "display",
            "flexDirection",
            "flexWrap",
            "flexShrink",
            "flexGrow",
            "flex",
            "alignItems",
            "alignSelf",
            "justifyContent",
            "overflow",
            "overflowX",
            "overflowY",
            "borderRadius",
            "border",
            "borderColor",
            "borderStyle",
            "textAlign",
            "textOverflow",
            "textTransform",
            "textDecoration",
            "whiteSpace",
            "wordBreak",
            "position",
            "cursor",
            "objectFit",
            "background",
            "bgcolor",
            "color",
            "boxShadow",
            "outline",
            "gap",
            "p",
            "px",
            "py",
            "pt",
            "pb",
            "pl",
            "pr",
            "m",
            "mx",
            "my",
            "mt",
            "mb",
            "ml",
            "mr",
            "width",
            "height",
            "minWidth",
            "maxWidth",
            "minHeight",
            "maxHeight",
            "fontSize",
            "fontWeight",
            "fontStyle",
            "lineHeight",
            "letterSpacing",
            "zIndex",
            "top",
            "right",
            "bottom",
            "left",
            "transition",
            "transform",
            "backgroundColor",
            "paddingX",
            "paddingY",
            "marginX",
            "marginY",
            "boxSizing",
            "padding",
            "margin",
            "WebkitBoxOrient",
            "WebkitLineClamp",
            "gridTemplateColumns",
            "rowGap",
            "justifyItems",
            "fontFamily",
            "borderTop",
            "borderLeft",
            "mixBlendMode",
            "outlineColor",
            "scrollbarWidth",
            "userSelect",
            "listStyle",
            "resize",
            "breakInside",
            "columnCount",
            "columnGap",
            // Component props whose values are enums, ids or URLs: MUI variants/sizes/anchors,
            // ARIA roles, link attributes, and our own color/shape/option props.
            "variant",
            "size",
            "role",
            "anchor",
            "anchorOrigin",
            "transformOrigin",
            "vertical",
            "horizontal",
            "severity",
            "component",
            "edge",
            "underline",
            "align",
            "justify",
            "target",
            "rel",
            "href",
            "autoComplete",
            "inputMode",
            "accept",
            "value",
            "fit",
            "radius",
            "buttonType",
            "iconColor",
            "textColor",
            "nameColor",
            "initialSection",
            "buttonPosition",
            "font",
            "verticalAlign",
            // Router patterns and Intl formatting options.
            "pattern",
            "path",
            "hour",
            "minute",
            "hour12",
            "weekday",
            "month",
            "day",
            "year",
            "notation",
            "timeZoneName",
            "borderBottom",
            // Firebase config keys, and status/error codes.
            "apiKey",
            "appId",
            "authDomain",
            "projectId",
            "region",
            "required",
            "status",
            "announcementStatus",
            "code",
            "key",
            "backgroundImage",
            "emulatorHost",
          ],
          ignoreFunctions: [
            "console.*",
            "cn",
            "cva",
            "clsx",
            "window.open",
            "Error",
            "*Error",
            // DOM event names and form fields, never copy.
            "*.addEventListener",
            "*.removeEventListener",
            "*.append",
            // Firestore paths, field names and query clauses, and callable-function names.
            "doc",
            "collection",
            "collectionGroup",
            "where",
            "orderBy",
            "getDoc",
            "*.call",
            "requiredString",
            "boolSetting",
            "findCollectionGroupDocument",
            // State-machine state names.
            "*.matches",
            // Locale/Intl construction, URL and history plumbing, storage and media-query calls.
            "Intl.*",
            "DOMException",
            "useMediaQuery",
            "ref",
            "page",
            "publish",
            "*.on",
            "*.has",
            "*.includes",
            "*.startsWith",
            "*.replaceState",
            "*.setCustomParameters",
            // State setters that take an enum or error code.
            "setEditing",
            "setErrorCode",
            // `new Set([...])` of codes and identifiers, never copy.
            "Set",
          ],
        },
      ],
      // MUI types `sx` colors as an open string, so a typo like "primary.mian" compiles and
      // silently renders nothing. Reject string literals that aren't theme palette paths.
      "no-restricted-syntax": [
        "error",
        ...["", " > ConditionalExpression", " > LogicalExpression"].map(
          (parent) => ({
            selector: colorLiteral(parent),
            message:
              'Not a theme color. Use a palette path ("primary.main"), a `colors` token, or a CSS keyword/#hex/rgb() value.',
          }),
        ),
      ],
    },
  },
  {
    // Modules that hold only technical strings (query keys, color and token tables, the
    // Flutter-catalog transpile script, generated SVG, HTTP plumbing). None contains copy.
    files: [
      "./client/new/src/queries/keys.ts",
      "./client/new/src/theme/colorPaths.ts",
      "./client/new/src/theme/tokens.ts",
      "./client/new/src/locales/flutterTranspile.ts",
      "./client/new/src/utils/placeholder.ts",
      "./client/new/src/api/cloudFunctions.ts",
      "./client/new/src/main.tsx",
    ],
    rules: {
      "lingui/no-unlocalized-strings": "off",
    },
  },
  {
    // Test code is full of testing-library selectors as well as test descriptions/fixture strings
    // that look like UI copy to the AST but aren't messages to translate.
    files: [
      "./client/new/src/__tests__/**/*.{ts,tsx}",
      "./client/new/src/app/**/i18n.ts",
    ],
    rules: {
      "lingui/no-unlocalized-strings": "off",
    },
  },
);
