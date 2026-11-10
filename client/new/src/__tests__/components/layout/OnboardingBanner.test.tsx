// @vitest-environment jsdom
import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useLocation } from "react-router";
import { describe, expect, it, vi } from "vitest";
import type { OnboardingStep } from "@/api/types";
import { community, template } from "@/__tests__/support/fixtures";
import { renderInCommunity } from "@/__tests__/support/renderWithProviders";
import { ONBOARDING_STEPS, OnboardingBanner, currentOnboardingStep } from "@/components/layout/OnboardingBanner";

function Location() {
  const { pathname } = useLocation();
  return <div data-testid="location">{pathname}</div>;
}

const withSteps = (onboardingSteps: OnboardingStep[]) => community({ onboardingSteps });

function renderBanner(onboardingSteps: OnboardingStep[], options: { mobile?: boolean; onDismiss?: () => void } = {}) {
  const onDismiss = options.onDismiss ?? vi.fn();
  const c = withSteps(onboardingSteps);
  return {
    onDismiss,
    ...renderInCommunity(
      <>
        <OnboardingBanner community={c} onDismiss={onDismiss} />
        <Location />
      </>,
      {
        community: c,
        status: "admin",
        mobile: options.mobile,
        api: { templates: { list: async () => [template()] } },
      },
    ),
  };
}

describe("currentOnboardingStep", () => {
  it("returns the first step in checklist order that is not done", () => {
    expect(currentOnboardingStep(withSteps([]))).toBe("brandSpace");
    expect(currentOnboardingStep(withSteps(["brandSpace"]))).toBe("createTemplate");
    // Order comes from the checklist, not from the order steps were completed in.
    expect(currentOnboardingStep(withSteps(["hostEvent", "brandSpace"]))).toBe("createTemplate");
  });

  it("returns null once every step is done", () => {
    expect(currentOnboardingStep(withSteps([...ONBOARDING_STEPS]))).toBeNull();
  });
});

describe("OnboardingBanner", () => {
  it("shows the next step and how far along the checklist is", async () => {
    renderBanner(["brandSpace"]);
    const banner = await screen.findByRole("region", { name: "Community onboarding" });
    expect(within(banner).getByText("Create a template")).toBeInTheDocument();
    expect(within(banner).getByText("1/4")).toBeInTheDocument();
    expect(within(banner).getByRole("progressbar", { name: "Onboarding progress" })).toHaveAttribute(
      "aria-valuenow",
      "25",
    );
  });

  it("renders nothing when onboarding is complete", async () => {
    renderBanner([...ONBOARDING_STEPS]);
    // The scope resolves before the banner would have rendered, so wait for it via the probe.
    await screen.findByTestId("location");
    expect(screen.queryByRole("region", { name: "Community onboarding" })).not.toBeInTheDocument();
  });

  it("calls onDismiss from the dismiss button", async () => {
    const user = userEvent.setup();
    const { onDismiss } = renderBanner([]);
    await user.click(await screen.findByRole("button", { name: "Dismiss onboarding" }));
    expect(onDismiss).toHaveBeenCalledTimes(1);
  });

  it.each([
    ["brandSpace", "Brand your space", "/space/civic-lab/admin/profile"],
    ["createTemplate", "Create a template", "/space/civic-lab/discuss"],
    ["inviteSomeone", "Invite your people", "/space/civic-lab/admin/profile"],
  ] as const)("sends you to the right place for the %s step", async (step, label, destination) => {
    const user = userEvent.setup();
    const done = ONBOARDING_STEPS.slice(0, ONBOARDING_STEPS.indexOf(step));
    renderBanner(done);
    await user.click(await screen.findByRole("button", { name: new RegExp(label) }));
    expect(screen.getByTestId("location")).toHaveTextContent(destination);
  });

  it("opens the create-event dialog for the host-an-event step", async () => {
    const user = userEvent.setup();
    renderBanner(["brandSpace", "createTemplate"]);
    await user.click(await screen.findByRole("button", { name: /Schedule an event/ }));
    expect(await screen.findByRole("heading", { name: "Choose Template" })).toBeInTheDocument();
    // Hosting an event opens the dialog in place instead of navigating.
    expect(screen.getByTestId("location").textContent).toBe("/");
  });

  it("works on a phone-width screen", async () => {
    const user = userEvent.setup();
    const { onDismiss } = renderBanner(["brandSpace"], { mobile: true });
    const banner = await screen.findByRole("region", { name: "Community onboarding" });
    expect(within(banner).getByText("1/4")).toBeInTheDocument();
    await user.click(within(banner).getByRole("button", { name: "Dismiss onboarding" }));
    expect(onDismiss).toHaveBeenCalledTimes(1);
  });
});
