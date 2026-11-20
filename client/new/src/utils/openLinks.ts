const ANCHOR = "a";
const NEW_TAB = "_blank";
const NO_OPENER = "noopener noreferrer";

// Opens each link in a new tab, a moment apart so the browser does not take them for a pop-up flood.
export async function openLinks(urls: readonly string[], pauseMs = 300): Promise<void> {
  for (const [index, url] of urls.entries()) {
    const link = document.createElement(ANCHOR);
    link.href = url;
    link.target = NEW_TAB;
    link.rel = NO_OPENER;
    document.body.append(link);
    link.click();
    link.remove();
    if (index < urls.length - 1) await new Promise((resolve) => setTimeout(resolve, pauseMs));
  }
}
