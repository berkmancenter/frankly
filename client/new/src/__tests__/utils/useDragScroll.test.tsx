// @vitest-environment jsdom
import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { useDragScroll } from "@/utils/useDragScroll";

function Strip({ onItemClick }: { onItemClick: () => void }) {
  const ref = useDragScroll<HTMLDivElement>();
  return (
    <div ref={ref} data-testid="strip">
      <button onClick={onItemClick}>Card</button>
    </div>
  );
}

// jsdom has no PointerEvent; MouseEvent carries the same fields the hook reads.
const pointer = (target: Element | Window, type: string, init: { x: number; button?: number; pointerType?: string }) => {
  const event = new MouseEvent(type, { clientX: init.x, button: init.button ?? 0, bubbles: true });
  Object.defineProperty(event, "pointerType", { value: init.pointerType ?? "mouse" });
  fireEvent(target, event);
};

describe("useDragScroll", () => {
  it("scrolls the element opposite to a mouse drag", () => {
    render(<Strip onItemClick={() => {}} />);
    const strip = screen.getByTestId("strip");
    strip.scrollLeft = 100;
    pointer(strip, "pointerdown", { x: 200 });
    pointer(window, "pointermove", { x: 150 });
    expect(strip.scrollLeft).toBe(150);
    pointer(window, "pointermove", { x: 250 });
    expect(strip.scrollLeft).toBe(50);
  });

  it("stops scrolling once the pointer is released", () => {
    render(<Strip onItemClick={() => {}} />);
    const strip = screen.getByTestId("strip");
    pointer(strip, "pointerdown", { x: 200 });
    pointer(window, "pointerup", { x: 200 });
    pointer(window, "pointermove", { x: 100 });
    expect(strip.scrollLeft).toBe(0);
  });

  it("ignores touch pointers and non-primary buttons", () => {
    render(<Strip onItemClick={() => {}} />);
    const strip = screen.getByTestId("strip");
    pointer(strip, "pointerdown", { x: 200, pointerType: "touch" });
    pointer(window, "pointermove", { x: 100 });
    expect(strip.scrollLeft).toBe(0);
    pointer(strip, "pointerdown", { x: 200, button: 2 });
    pointer(window, "pointermove", { x: 100 });
    expect(strip.scrollLeft).toBe(0);
  });

  it("swallows the click that ends a drag, but not a plain click", () => {
    const onItemClick = vi.fn();
    render(<Strip onItemClick={onItemClick} />);
    const strip = screen.getByTestId("strip");
    const card = screen.getByRole("button", { name: "Card" });

    pointer(strip, "pointerdown", { x: 200 });
    pointer(window, "pointermove", { x: 120 });
    pointer(window, "pointerup", { x: 120 });
    fireEvent.click(card);
    expect(onItemClick).not.toHaveBeenCalled();

    // The suppression is one-shot: the next click goes through.
    fireEvent.click(card);
    expect(onItemClick).toHaveBeenCalledTimes(1);
  });

  it("lets a click through after a tiny wobble", () => {
    const onItemClick = vi.fn();
    render(<Strip onItemClick={onItemClick} />);
    const strip = screen.getByTestId("strip");
    pointer(strip, "pointerdown", { x: 200 });
    pointer(window, "pointermove", { x: 198 });
    pointer(window, "pointerup", { x: 198 });
    fireEvent.click(screen.getByRole("button", { name: "Card" }));
    expect(onItemClick).toHaveBeenCalledTimes(1);
  });
});
