import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { BlockQuote, Box, Dimmer, Icon, Section, Stack } from '../components';

type Bounty = {
  name: string;
  help: string;
  difficulty: string;
  reward: string;
  claimed: BooleanLike;
};

type Data = {
  time_left: string;
  bounties: Bounty[];
};

const BountyDisplay = (props: { bounty: Bounty }) => {
  const { bounty } = props;

  const difficulty_to_color = {
    'easy': 'good',
    'medium': 'average',
    'hard': 'bad',
  };

  return (
    <Section>
      {!!bounty.claimed && (
        <Dimmer>
          <Stack>
            <Stack.Item>
              <Icon name="user-secret" color="bad" />
            </Stack.Item>
            <Stack.Item>
              <i>Claimed!</i>
            </Stack.Item>
          </Stack>
        </Dimmer>
      )}
      <Stack vertical ml={1}>
        <Stack.Item>
          <Box color={difficulty_to_color[bounty.difficulty.toLowerCase()]}>
            {bounty.name}.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>{bounty.help}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <i>Reward: {bounty.reward}</i>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const SpyUplink = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { bounties, time_left } = data;
  return (
    <Window width={450} height={615} theme={'ntos_darkmode'}>
      <Window.Content>
        <Section
          fill
          title="Spy Bounties"
          scrollable
          buttons={<Box width="50%">Time until refresh: {time_left}</Box>}>
          <Stack vertical fill>
            <Stack.Item>
              {bounties.map((bounty) => (
                <Stack.Item key={bounty.name} className="candystripe">
                  <BountyDisplay bounty={bounty} />
                </Stack.Item>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
