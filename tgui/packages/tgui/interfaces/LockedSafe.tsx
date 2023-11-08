import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Flex } from '../components';
import { Window } from '../layouts';
import { NukeKeypad } from './NuclearBomb';

type Data = {
  input_code: string;
  locked: BooleanLike;
  lock_set: BooleanLike;
};

export const LockedSafe = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { input_code, locked, lock_set } = data;
  return (
    <Window width={300} height={400} theme="ntos">
      <Window.Content>
        <Box m="6px">
          <Box mb="6px" className="NuclearBomb__displayBox">
            {input_code}
          </Box>
          <Box className="NuclearBomb__displayBox">
            {!lock_set && 'No password set.'}
            {!!lock_set && (!locked ? 'Unlocked' : 'Locked')}
          </Box>
          <Flex ml="3px">
            <Flex.Item>
              <NukeKeypad />
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
