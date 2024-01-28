import { toTitleCase } from 'common/string';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Image,
  NoticeBox,
  Section,
  Stack,
  Table,
  Icon,
  Dimmer,
} from '../components';
import { TableCell } from '../components/Table';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialIcon } from './Fabrication/MaterialIcon';
import { Material } from './Fabrication/Types';

type Data = {
  SHEET_MATERIAL_AMOUNT: number;
  materials: Material[];
  design?: Design;
  busy:  boolean;
};

type Design = {
  name: string;
  icon: string;
  requiredMaterials: Omit<Material, 'ref' | 'color'>[];
  canPrint: boolean;
  disableReason?: string;
};

export const Flatpacker = (props: any) => {
  const { act, data } = useBackend<Data>();
  const { SHEET_MATERIAL_AMOUNT, materials, design, busy } = data;

  return (
    <Window width={400} height={445} title="Flatpacker">
      <Window.Content>
	  {!!busy && (
              <Dimmer
                style={{
                  fontSize: '2em',
                  textAlign: 'center',
                }}
              >
                <Icon name="cog" spin />
                {' Flatpacking...'}
              </Dimmer>
            )}
        <Stack fill vertical align="stretch">
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Section>
                  <Box
                    className="FabricatorRecipe__Label"
                    fontSize="18px"
                    font="Helvetica"
                  >
                    {design ? toTitleCase(design.name) : 'No Board!'}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Button
                  tooltip="Eject Board"
                  tooltipPosition="left"
                  height="37px"
                  width="37px"
                  onClick={() => act('ejectBoard')}
                >
                  <Icon name="eject" size="1.5" mt="0.8rem" ml="0rem" />
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            {design ? (
              <Stack fill>
                <Stack.Item width={15}>
                  <BoardPreview design={design} onPrint={() => act('build')} />
                </Stack.Item>
                <Stack.Item grow>
                  <CostPreview
                    SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                    materials={design.requiredMaterials}
                  />
                </Stack.Item>
              </Stack>
            ) : (
              <NoticeBox>No circuit present!</NoticeBox>
            )}
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              <MaterialAccessBar
                availableMaterials={materials}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                onEjectRequested={(material, amount) =>
                  act('eject', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type BoardPreviewProps = {
  design: Design;
  onPrint: () => void;
};

const BoardPreview = (props: BoardPreviewProps) => {
  const { design, onPrint } = props;

  return (
    <Section fill>
      <Stack fill vertical justify="space-between">
        <Stack.Item>
          <Stack vertical align="center">
            <Stack.Item>
              <Image
                width="128px"
                height="128px"
                src={`data:image/jpeg;base64,${design.icon}`}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            bold
            fluid
            p={1}
            icon="cog"
            fontSize={1.2}
            textAlign="center"
            disabled={!design || !design.canPrint}
            tooltip={design.disableReason}
            tooltipPosition="bottom"
            onClick={() => onPrint()}
          >
            Print
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type CostPreviewProps = {
  SHEET_MATERIAL_AMOUNT: number;
  materials?: Material[];
};

const CostPreview = (props: CostPreviewProps) => {
  const { materials, SHEET_MATERIAL_AMOUNT } = props;

  return (
    <Section fill>
      {materials ? (
        <Table>
          {materials.map((material) => (
            <Table.Row key={material.name} collapsing className="candystripe">
              <Table.Cell verticalAlign="middle">
                <MaterialIcon
                  materialName={material.name}
                  sheets={material.count / SHEET_MATERIAL_AMOUNT}
                />
              </Table.Cell>
              <TableCell verticalAlign="middle">
                {toTitleCase(material.name)}
              </TableCell>
              <Table.Cell verticalAlign="middle">
                &times;{(material.count / SHEET_MATERIAL_AMOUNT).toFixed(2)}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <NoticeBox>No materials required!</NoticeBox>
      )}
    </Section>
  );
};
