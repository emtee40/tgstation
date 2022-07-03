import { useBackend } from '../../backend';
import { Box, Button, LabeledList, ProgressBar, Tooltip } from '../../components';
import { OperatorData, MechaUtility } from './data';

export const UtilityModulesPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { mech_equipment } = data;
  return (
    <Box style={{ 'overflow': 'auto', 'max-height': '16rem' }}>
      <LabeledList>
        {mech_equipment['utility'].map((module, i) => (
          <LabeledList.Item key={i} label={module.name} verticalAlign="middle">
            {module.snowflake.snowflake_id ? (
              <Snowflake module={module} />
            ) : (
              <Box width="100%" display="flex" flexDirection="row" alignItems="center">
                <Button
                  verticalAlignContent="middle"
                  content={(module.activated ? 'En' : 'Dis') + 'abled'}
                  onClick={() =>
                    act('equip_act', {
                      ref: module.ref,
                      gear_action: 'toggle',
                    })
                  }
                  selected={module.activated}
                />
                <Button
                  verticalAlignContent="middle"
                  content={'Detach'}
                  onClick={() =>
                    act('equip_act', {
                      ref: module.ref,
                      gear_action: 'detach',
                    })
                  }
                />
              </Box>
            )}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  );
};

const MECHA_SNOWFLAKE_ID_EJECTOR = 'ejector_snowflake';
const MECHA_SNOWFLAKE_ID_EXTINGUISHER = 'extinguisher_snowflake';

// Handles all the snowflake buttons and whatever
const Snowflake = (props: { module: MechaUtility }, context) => {
  const { snowflake } = props.module;
  switch (snowflake['snowflake_id']) {
    case MECHA_SNOWFLAKE_ID_EJECTOR:
      return <SnowflakeEjector module={props.module} />;
    case MECHA_SNOWFLAKE_ID_EXTINGUISHER:
      return <SnowflakeExtinguisher module={props.module} />;
    default:
      return null;
  }
};

const EjectorLabel = (props: { name: string }) => {
  const { name } = props;
  return (
    <Tooltip content={name} position="top">
      <Box
        style={{
          'display': 'inline-block',
          'vertical-align': 'middle',
          'max-width': '6rem',
          'overflow-x': 'hidden',
          'text-overflow': 'ellipsis',
        }}>
        {`${name}:`}
      </Box>
    </Tooltip>
  );
};

const SnowflakeEjector = (props: { module: MechaUtility }, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { cargo } = props.module.snowflake;
  return (
    <LabeledList>
      {cargo.map((item, i) => (
        <LabeledList.Item key={i} label={<EjectorLabel name={item.name} />}>
          <Button
            onClick={() =>
              act('equip_act', {
                ref: props.module.ref,
                cargoref: item.ref,
                gear_action: 'eject',
              })
            }>
            {'Eject'}
          </Button>
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};

const SnowflakeExtinguisher = (props: { module: MechaUtility }, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  return (
    <>
      <ProgressBar
        value={props.module.snowflake.reagents}
        minValue={0}
        maxValue={props.module.snowflake.total_reagents}>
        {props.module.snowflake.reagents}
      </ProgressBar>
      <Button
        tooltip={'ACTIVATE'}
        color={'red'}
        disabled={
          props.module.snowflake.reagents < props.module.snowflake.minimum_requ
            ? 1
            : 0
        }
        icon={'fire-extinguisher'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'activate',
          })
        }
      />
      <Button
        tooltip={'REFILL'}
        icon={'fill'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'refill',
          })
        }
      />
      <Button
        tooltip={'REPAIR'}
        icon={'wrench'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'repair',
          })
        }
      />
      <Button
        tooltip={'DETACH'}
        icon={'arrow-down'}
        onClick={() =>
          act('equip_act', {
            ref: props.module.ref,
            gear_action: 'detach',
          })
        }
      />
    </>
  );
};
