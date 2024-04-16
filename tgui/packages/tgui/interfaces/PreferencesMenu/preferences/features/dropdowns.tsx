import { classes } from 'common/react';
import { capitalizeFirst } from 'common/string';
import { ReactNode } from 'react';

import { Box, Dropdown, Stack } from '../../../../components';
import { Feature, FeatureChoicedServerData, FeatureValueProps } from './base';

type DropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
> &
  Partial<{
    disabled: boolean;
    buttons: boolean;
  }>;

type IconnedDropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
>;

export type FeatureWithIcons<T> = Feature<
  { value: T },
  T,
  FeatureChoicedServerData
>;

export function FeatureDropdownInput(props: DropdownInputProps) {
  const { serverData, disabled, buttons, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names } = serverData;

  const dropdownOptions = choices.map((choice) => {
    let displayText: ReactNode = display_names
      ? display_names[choice]
      : capitalizeFirst(choice);

    return {
      displayText,
      value: choice,
    };
  });

  return (
    <Dropdown
      buttons={buttons}
      disabled={disabled}
      onSelected={handleSetValue}
      displayText={value && capitalizeFirst(value)}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names, icons } = serverData;

  const dropdownOptions = choices.map((choice) => {
    let displayText: ReactNode = display_names
      ? display_names[choice]
      : capitalizeFirst(choice);

    if (icons?.[choice]) {
      displayText = (
        <Stack>
          <Stack.Item>
            <Box
              className={classes(['preferences32x32', icons[choice]])}
              style={{ transform: 'scale(0.8)' }}
            />
          </Stack.Item>
          <Stack.Item grow>{displayText}</Stack.Item>
        </Stack>
      );
    }

    return {
      displayText,
      value: choice,
    };
  });

  return (
    <Dropdown
      buttons
      displayText={value && capitalizeFirst(value)}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value}
      width="100%"
    />
  );
}
