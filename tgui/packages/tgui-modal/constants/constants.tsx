/** Radio channels */
export const CHANNELS: string[] = ['Say', 'Radio', 'Me', 'OOC'];

type WindowSize = Record<string, number>;

/** Window sizes in pixels */
export const SIZE: WindowSize = {
  small: 30,
  medium: 50,
  large: 70,
  width: 231,
};

type RadioPrefix = Record<string, { id: string; label: string }>;

/** Radio prefixes */
export const RADIO_PREFIXES: RadioPrefix = {
  ':a ': {
    id: 'hive',
    label: 'Hive',
  },
  ':b ': {
    id: 'binary',
    label: '0101',
  },
  ':c ': {
    id: 'command',
    label: 'Cmd',
  },
  ':e ': {
    id: 'engi',
    label: 'Engi',
  },
  ':m ': {
    id: 'medical',
    label: 'Med',
  },
  ':n ': {
    id: 'science',
    label: 'Sci',
  },
  ':o ': {
    id: 'ai',
    label: 'AI',
  },
  ':s ': {
    id: 'security',
    label: 'Sec',
  },
  ':t ': {
    id: 'syndicate',
    label: 'Syndi',
  },
  ':u ': {
    id: 'supply',
    label: 'Supp',
  },
  ':v ': {
    id: 'service',
    label: 'Svc',
  },
  ':y ': {
    id: 'centcom',
    label: 'CCom',
  },
};
