import { Box, Dimmer, Section, Stack } from '../../components';
import { ObjectiveElement } from './ObjectiveMenu';

type PrimaryObjectiveMenuProps = {
  primary_objectives;
  final_objective;
};

export const PrimaryObjectiveMenu = (
  props: PrimaryObjectiveMenuProps,
  context
) => {
  const { primary_objectives, final_objective } = props;
  return (
    <Section fill>
      <Section>
        <Box mt={3} mb={3} bold fontSize={1.2} align="center" color="white">
          {
            'Agent, your Primary Objectives are as follows. Complete these at all costs.'
          }
        </Box>
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          {
            'Completing Secondary Objectives may allow you to aquire additional equipment.'
          }
        </Box>
      </Section>
      {final_objective && (
        <Dimmer>
          <Box
            color="red"
            fontFamily={'Bahnschrift'}
            fontSize={3}
            align={'top'}
            as="span">
            PRIORITY MESSAGE
            <br />
            SOURCE: xxx.xxx.xxx.224:41394
            <br />
            <br />
            \\Debrief in progress.
            <br />
            \\Final Objective confirmed complete. <br />
            \\Your work is done here, agent.
            <br />
            <br />
            CONNECTION CLOSED_
          </Box>
        </Dimmer>
      )}
      <Section>
        <Stack vertical fill scrollable>
          {primary_objectives.map((prim_obj, index) => (
            <Stack.Item key={index}>
              <ObjectiveElement
                key={prim_obj.id}
                name={prim_obj['task_name']}
                description={prim_obj['task_text']}
                reputation={{
                  minutesLessThan: 0,
                  title: 'none',
                  gradient:
                    index === primary_objectives.length - 1
                      ? 'reputation-good'
                      : 'reputation-very-good',
                }}
                telecrystalReward={0}
                telecrystalPenalty={0}
                progressionReward={0}
                originalProgression={0}
                hideTcRep={1}
                canAbort={false}
                grow={false}
                finalObjective={false}
                hideFooter={1}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Section>
  );
};
