import { createLogger } from './logging';
import { callByond } from './byond';

const logger = createLogger('hotkeys');

// Key codes
export const KEY_TAB = 9;
export const KEY_ENTER = 13;
export const KEY_SHIFT = 16;
export const KEY_CTRL = 17;
export const KEY_ALT = 18;
export const KEY_ESCAPE = 27;
export const KEY_SPACE = 32;
export const KEY_0 = 48;
export const KEY_1 = 49;
export const KEY_2 = 50;
export const KEY_3 = 51;
export const KEY_4 = 52;
export const KEY_5 = 53;
export const KEY_6 = 54;
export const KEY_7 = 55;
export const KEY_8 = 56;
export const KEY_9 = 57;
export const KEY_A = 65;
export const KEY_B = 66;
export const KEY_C = 67;
export const KEY_D = 68;
export const KEY_E = 69;
export const KEY_F = 70;
export const KEY_G = 71;
export const KEY_H = 72;
export const KEY_I = 73;
export const KEY_J = 74;
export const KEY_K = 75;
export const KEY_L = 76;
export const KEY_M = 77;
export const KEY_N = 78;
export const KEY_O = 79;
export const KEY_P = 80;
export const KEY_Q = 81;
export const KEY_R = 82;
export const KEY_S = 83;
export const KEY_T = 84;
export const KEY_U = 85;
export const KEY_V = 86;
export const KEY_W = 87;
export const KEY_X = 88;
export const KEY_Y = 89;
export const KEY_Z = 90;
export const KEY_EQUAL = 187;
export const KEY_MINUS = 189;

const MODIFIER_KEYS = [
  KEY_CTRL,
  KEY_ALT,
  KEY_SHIFT,
];

const NO_PASSTHROUGH_KEYS = [
  KEY_ESCAPE,
  KEY_ENTER,
  KEY_SPACE,
  KEY_TAB,
  ...MODIFIER_KEYS,
];

// Tracks the "pressed" state of keys
const keyState = {};

const makeComboString = (ctrlKey, altKey, shiftKey, keyCode) => {
  let str = '';
  if (ctrlKey) {
    str += 'Ctrl+';
  }
  if (altKey) {
    str += 'Alt+';
  }
  if (shiftKey) {
    str += 'Shift+';
  }
  if (keyCode >= 48 && keyCode <= 90) {
    str += String.fromCharCode(keyCode);
  }
  else {
    str += '[' + keyCode + ']';
  }
  return str;
};

const getKeyData = e => {
  const keyCode = window.event ? e.which : e.keyCode;
  const { ctrlKey, altKey, shiftKey } = e;
  return {
    keyCode,
    ctrlKey,
    altKey,
    shiftKey,
    hasModifierKeys: ctrlKey || altKey || shiftKey,
    keyString: makeComboString(ctrlKey, altKey, shiftKey, keyCode),
  };
};

// Keyboard passthrough logic. This allows you to keep doing things
// in game while the browser window is focused.
const handlePassthrough = (e, eventType) => {
  const { keyCode, keyString, hasModifierKeys } = getKeyData(e);
  if (e.defaultPrevented) {
    return;
  }
  if (e.target) {
    const name = e.target.localName;
    if (name === 'input' || name === 'textarea') {
      return;
    }
  }
  if (hasModifierKeys) {
    return;
  }
  if (NO_PASSTHROUGH_KEYS.includes(keyCode)) {
    return;
  }
  // Prevent spam of keydown events
  if (eventType === 'keydown' && keyState[keyCode]) {
    return;
  }
  // Send this keypress to BYOND
  logger.debug('passthrough', [eventType, keyString]);
  if (eventType === 'keydown') {
    return callByond('', { __keydown: keyCode });
  }
  if (eventType === 'keyup') {
    return callByond('', { __keyup: keyCode });
  }
};

/**
 * Cleanup procedure for keyboard passthrough, which should be called
 * whenever you're unloading tgui.
 */
export const releaseHeldKeys = () => {
  for (let keyCode of Object.keys(keyState)) {
    if (keyState[keyCode]) {
      logger.log(`releasing [${keyCode}] key`);
      keyState[keyCode] = false;
      callByond('', { __keyup: keyCode });
    }
  }
};

const handleHotKey = (e, eventType, dispatch) => {
  if (eventType !== 'keyup') {
    return;
  }
  const keyData = getKeyData(e);
  const { keyCode, hasModifierKeys, keyString } = keyData;
  // Dispatch a detected hotkey as a store action
  if (hasModifierKeys && !MODIFIER_KEYS.includes(keyCode)) {
    logger.log(keyString);
    dispatch({
      type: 'hotKey',
      payload: keyData,
    });
  }
};

// Middleware
export const hotKeyMiddleware = store => {
  const { dispatch } = store;
  // Subscribe to key events
  document.addEventListener('keydown', e => {
    const keyCode = window.event ? e.which : e.keyCode;
    handlePassthrough(e, 'keydown');
    keyState[keyCode] = true;
  });
  document.addEventListener('keyup', e => {
    const keyCode = window.event ? e.which : e.keyCode;
    handlePassthrough(e, 'keyup');
    handleHotKey(e, 'keyup', dispatch);
    keyState[keyCode] = false;
  });
  // Pass through store actions (do nothing)
  return next => action => next(action);
};

// Reducer
export const hotKeyReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'hotKey') {
    const { ctrlKey, altKey, keyCode } = payload;

    // Toggle kitchen sink mode
    if (ctrlKey && altKey && keyCode === KEY_EQUAL) {
      return {
        ...state,
        showKitchenSink: !state.showKitchenSink,
      };
    }

    return state;
  }

  return state;
};
