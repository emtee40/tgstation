import { useBackend } from '../backend';
import { Box, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = `No information available! Ask for assistance if needed.`;

const boxHelp = [
  {
    color: 'purple',
    text: 'Study the area and do what needs to be done to recover the crate.',
    icon: 'search-location',
    title: 'Search',
  },
  {
    color: 'green',
    text: 'Bring the crate to the designated sending location in the safehouse. The area can manifest as many things: A carpet, circuit tiles, or glowing floors.',
    icon: 'boxes',
    'title': 'Recover',
  },
  {
    color: 'blue',
    text: 'You can disconnect from the domain and return to your physical body. The ladder represents the safest way to do this, but other, unsafe means are also available.',
    icon: 'plug',
    title: 'Disconnect',
  },
  {
    color: 'yellow',
    text: 'When triggered, the proximity alert system offers a safe method to disconnect. You can activate it, but be aware that domains cannot be paused.',
    icon: 'id-badge',
    title: 'Proximity Alert',
  },
  {
    color: 'gold',
    text: 'Generating avatars costs tremendous bandwidth. Do not waste them. ',
    icon: 'coins',
    title: 'Limited Attempts',
  },
  {
    color: 'red',
    text: 'Remember that you are physically linked to this presence. You are a foreign body in a hostile environment. It will attempt to forcefully eject you.',
    icon: 'skull-crossbones',
    title: 'Realized Danger',
  },
] as const;

export const AvatarHelp = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window title="Domain Information" width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section fill scrollable title="Welcome to the Virtual Domain." />
          </Stack.Item>
          <Stack.Item grow={3}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Stack fill>
                  {[0, 1].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[2, 3].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[4, 5].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Detected Domain Information">
              {help_text}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// I wish I had media queries
const BoxHelp = (props: { index: number }, context) => {
  const { index } = props;

  return (
    <Stack.Item grow>
      <Section
        color="label"
        fill
        minHeight={10}
        title={
          <Stack align="center">
            <Icon
              color={boxHelp[index].color}
              mr={1}
              name={boxHelp[index].icon}
            />
            <Box>{boxHelp[index].title}</Box>
          </Stack>
        }>
        {boxHelp[index].text}
      </Section>
    </Stack.Item>
  );
};
