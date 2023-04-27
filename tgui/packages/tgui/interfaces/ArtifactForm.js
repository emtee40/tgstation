import { useBackend } from '../backend';

import { Box, Section, ProgressBar, Button } from '../components';
import { Window } from '../layouts';

export const ArtifactForm = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    allorigins,
    chosenorigin,
    alltypes,
    chosentype,
    alltriggers,
    chosentriggers,
  } = data;
  return (
    <Window width={480} height={400} title={'Analysis Form'} theme={'paper'}>
      <Window.Content>
        <Section title="Origin">
          {Object.keys(allorigins).map((key) => (
            <Button
              key={key}
              icon={
                chosenorigin === allorigins[key] ? 'check-square-o' : 'square-o'
              }
              content={key}
              selected={chosenorigin === allorigins[key]}
              onClick={() =>
                act('origin', {
                  origin: allorigins[key],
                })
              }
            />
          ))}
        </Section>
        <Section title="Type">
          {alltypes.map((x) => (
            <Button
              key={x}
              icon={chosentype === x ? 'check-square-o' : 'square-o'}
              content={x}
              selected={chosentype === x}
              onClick={() =>
                act('type', {
                  type: x,
                })
              }
            />
          ))}
        </Section>
        <Section title="Triggers">
          {Object.keys(alltriggers).map((trig) => (
            <Button
              key={trig}
              icon={
                chosentriggers.includes(trig) ? 'check-square-o' : 'square-o'
              }
              content={trig}
              selected={chosentriggers.includes(trig)}
              onClick={() =>
                act('trigger', {
                  trigger: trig,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
