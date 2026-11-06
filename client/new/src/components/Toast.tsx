import Alert from '@mui/material/Alert';
import Snackbar from '@mui/material/Snackbar';
import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react';

export type ToastType = 'regular' | 'success' | 'error';

interface ToastItem {
  key: number;
  message: string;
  type: ToastType;
}

interface ToastApi {
  show(message: string, type?: ToastType): void;
  success(message: string): void;
  error(message: string): void;
}

const ToastContext = createContext<ToastApi | null>(null);

/**
 * Toasts are a UI *service*, not shared state: the provider owns a one-item queue and exposes
 * `show()`. Nothing else can read or mutate it.
 */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [queue, setQueue] = useState<ToastItem[]>([]);
  const [current, setCurrent] = useState<ToastItem | null>(null);
  const [open, setOpen] = useState(false);

  const show = useCallback((message: string, type: ToastType = 'regular') => {
    setQueue((q) => [...q, { key: Date.now() + Math.random(), message, type }]);
  }, []);

  // Pull the next toast when idle.
  if (!current && queue.length > 0) {
    const [next, ...rest] = queue;
    setQueue(rest);
    setCurrent(next!);
    setOpen(true);
  }

  const api = useMemo<ToastApi>(
    () => ({
      show,
      success: (m) => show(m, 'success'),
      error: (m) => show(m, 'error'),
    }),
    [show],
  );

  return (
    <ToastContext.Provider value={api}>
      {children}
      <Snackbar
        key={current?.key}
        open={open}
        autoHideDuration={4000}
        onClose={(_e, reason) => {
          if (reason === 'clickaway') return;
          setOpen(false);
        }}
        slotProps={{ transition: { onExited: () => setCurrent(null) } }}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert
          severity={current?.type === 'error' ? 'error' : current?.type === 'success' ? 'success' : 'info'}
          icon={current?.type === 'regular' ? false : undefined}
          variant="filled"
          onClose={() => setOpen(false)}
          sx={{
            bgcolor: current?.type === 'error' ? 'm3.error' : current?.type === 'success' ? '#1a6e2e' : 'm3.inverseSurface',
            color: current?.type === 'regular' ? 'm3.onInverseSurface' : '#fff',
            alignItems: 'center',
          }}
        >
          {current?.message}
        </Alert>
      </Snackbar>
    </ToastContext.Provider>
  );
}

export function useToast(): ToastApi {
  const api = useContext(ToastContext);
  if (!api) throw new Error('useToast must be used inside <ToastProvider>');
  return api;
}
