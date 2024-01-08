import { multiline } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { BAYS } from './constants';
import { PodLauncherData } from './types';

export function PodBays(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { bayNumber } = data;

  return (
    <Section
      fill
      title="Bay"
      buttons={
        <>
          <Button
            icon="trash"
            color="transparent"
            onClick={() => act('clearBay')}
            tooltip={multiline`
              Clears everything
              from the selected bay`}
            tooltipPosition="top-end"
          />
          <Button
            icon="question"
            color="transparent"
            tooltip={multiline`
              Each option corresponds
              to an area on centcom.
              Launched pods will
              be filled with items
              in these areas according
              to the "Load from Bay"
              options at the top left.`}
            tooltipPosition="top-end"
          />
        </>
      }
    >
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          onClick={() => act('switchBay', { bayNumber: '' + (i + 1) })}
          selected={bayNumber === '' + (i + 1)}
          tooltipPosition="bottom-end"
        >
          {bay.title}
        </Button>
      ))}
    </Section>
  );
}
