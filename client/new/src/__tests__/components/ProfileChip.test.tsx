// @vitest-environment jsdom
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { me, user } from "@/__tests__/support/fixtures";
import { renderWithProviders, type RenderOptions } from "@/__tests__/support/renderWithProviders";
import { ProfileChip } from "@/components/ProfileChip";

const ada = user({ id: "u1", displayName: "Ada Lovelace", about: "First programmer." });
const grace = user({ id: "u2", displayName: "Grace Hopper", about: "Compiler pioneer." });

// The signed-in user is Ada; `users.get` knows both.
const api: NonNullable<RenderOptions["api"]> = {
  me: { get: async () => me({ user: ada }) },
  users: { get: async (id: string) => (id === "u2" ? grace : ada) },
};

describe("ProfileChip", () => {
  it("shows the user's avatar initial and display name", async () => {
    renderWithProviders(<ProfileChip userId="u2" />, { api });

    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(screen.getByText("G")).toBeInTheDocument();
  });

  it("shows Anonymous, without fetching, when there is no user id", () => {
    const { api: fakeApi } = renderWithProviders(<ProfileChip userId={undefined} />, { api });

    expect(screen.getByText("Anonymous")).toBeInTheDocument();
    expect(fakeApi.users.get).not.toHaveBeenCalled();
  });

  it("shows Anonymous when the user cannot be loaded", async () => {
    const { api: fakeApi } = renderWithProviders(<ProfileChip userId="u9" />, {
      api: {
        me: api.me,
        users: {
          get: async () => {
            throw new Error("not found");
          },
        },
      },
    });

    await vi.waitFor(() => expect(fakeApi.users.get).toHaveBeenCalledWith("u9"));
    expect(screen.getByText("Anonymous")).toBeInTheDocument();
  });

  it("says You for the signed-in user only with showIsYou", async () => {
    renderWithProviders(
      <>
        <ProfileChip userId="u1" showIsYou />
        <ProfileChip userId="u2" showIsYou />
      </>,
      { api },
    );

    expect(await screen.findByText("You")).toBeInTheDocument();
    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(screen.queryByText("Ada Lovelace")).not.toBeInTheDocument();
  });

  it("keeps the name but appends (you) with youSuffix", async () => {
    renderWithProviders(
      <>
        <ProfileChip userId="u1" youSuffix />
        <ProfileChip userId="u2" youSuffix />
      </>,
      { api },
    );

    expect(await screen.findByText("Ada Lovelace (you)")).toBeInTheDocument();
    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
  });

  it("hides the name with showName=false but keeps an accessible label", async () => {
    renderWithProviders(<ProfileChip userId="u2" showName={false} />, { api });

    expect(await screen.findByRole("button", { name: "Profile of Grace Hopper" })).toBeInTheDocument();
    expect(screen.queryByText("Grace Hopper")).not.toBeInTheDocument();
  });

  it("is not clickable when enableOnTap is off", async () => {
    renderWithProviders(<ProfileChip userId="u2" enableOnTap={false} />, { api });

    expect(await screen.findByText("Grace Hopper")).toBeInTheDocument();
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("opens the profile drawer on click and closes it again", async () => {
    const user = userEvent.setup();
    renderWithProviders(<ProfileChip userId="u2" />, { api });
    await screen.findByText("Grace Hopper");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: /Grace Hopper/ }));

    expect(await screen.findByRole("heading", { name: "Grace Hopper" })).toBeInTheDocument();
    expect(screen.getByText("Compiler pioneer.")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Close" }));
    expect(screen.queryByRole("heading", { name: "Grace Hopper" })).not.toBeInTheDocument();
    expect(screen.queryByText("Compiler pioneer.")).not.toBeInTheDocument();
  });
});
