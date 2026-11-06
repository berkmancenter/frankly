import { ActionButton, type ActionButtonProps } from './ActionButton';

/** `ThickOutlineButton`: an outline ActionButton with no minimum width. */
export function ThickOutlineButton(props: Omit<ActionButtonProps, 'type'>) {
  return <ActionButton type="outline" minWidth={0} height={props.height ?? 44} {...props} />;
}
