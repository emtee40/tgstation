import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Stack } from "../components";
import { Window } from "../layouts";

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = "50px";

type AlternateAction = {
  icon: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  knot: {
    icon: "shoe-prints",
    text: "Knot",
  },

  untie: {
    icon: "shoe-prints",
    text: "Untie",
  },

  unknot: {
    icon: "shoe-prints",
    text: "Unknot",
  },

  enable_internals: {
    icon: "tg-air-tank",
    text: "Enable internals",
  },

  disable_internals: {
    icon: "tg-air-tank-slash",
    text: "Disable internals",
  },
};

const SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
    additionalComponent?: JSX.Element;
  }
> = {
  eyes: {
    displayName: "eyewear",
    gridSpot: getGridSpotKey([0, 1]),
    image: "inventory-glasses.png",
  },

  head: {
    displayName: "headwear",
    gridSpot: getGridSpotKey([0, 2]),
    image: "inventory-head.png",
  },

  neck: {
    displayName: "neckwear",
    gridSpot: getGridSpotKey([1, 1]),
    image: "inventory-neck.png",
  },

  mask: {
    displayName: "mask",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-mask.png",
  },

  corgi_collar: {
    displayName: "collar",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-collar.png",
  },

  ears: {
    displayName: "earwear",
    gridSpot: getGridSpotKey([1, 3]),
    image: "inventory-ears.png",
  },

  parrot_headset: {
    displayName: "headset",
    gridSpot: getGridSpotKey([1, 3]),
    image: "inventory-ears.png",
  },

  handcuffs: {
    displayName: "handcuffs",
    gridSpot: getGridSpotKey([1, 4]),
  },

  legcuffs: {
    displayName: "legcuffs",
    gridSpot: getGridSpotKey([1, 5]),
  },

  jumpsuit: {
    displayName: "uniform",
    gridSpot: getGridSpotKey([2, 1]),
    image: "inventory-uniform.png",
  },

  suit: {
    displayName: "suit",
    gridSpot: getGridSpotKey([2, 2]),
    image: "inventory-suit.png",
  },

  gloves: {
    displayName: "gloves",
    gridSpot: getGridSpotKey([2, 3]),
    image: "inventory-gloves.png",
  },

  right_hand: {
    displayName: "right hand",
    gridSpot: getGridSpotKey([2, 4]),
    image: "inventory-hand_r.png",
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    displayName: "left hand",
    gridSpot: getGridSpotKey([2, 5]),
    image: "inventory-hand_l.png",
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  shoes: {
    displayName: "shoes",
    gridSpot: getGridSpotKey([3, 2]),
    image: "inventory-shoes.png",
  },

  suit_storage: {
    displayName: "suit storage item",
    gridSpot: getGridSpotKey([4, 0]),
    image: "inventory-suit_storage.png",
  },

  id: {
    displayName: "ID",
    gridSpot: getGridSpotKey([4, 1]),
    image: "inventory-id.png",
  },

  belt: {
    displayName: "belt",
    gridSpot: getGridSpotKey([4, 2]),
    image: "inventory-belt.png",
  },

  back: {
    displayName: "backpack",
    gridSpot: getGridSpotKey([4, 3]),
    image: "inventory-back.png",
  },

  left_pocket: {
    displayName: "left pocket",
    gridSpot: getGridSpotKey([4, 4]),
    image: "inventory-pocket.png",
  },

  right_pocket: {
    displayName: "right pocket",
    gridSpot: getGridSpotKey([4, 5]),
    image: "inventory-pocket.png",
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
}

type StripMenuItem =
  | null
  | {
      icon: string;
      name: string;
      alternate?: string;
    }
  | {
      obscured: ObscuringLevel;
    };

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  name: string;
};

type GridSpotKey = string;

function getGridSpotKey(spot: [number, number]): GridSpotKey {
  return `${spot[0]}/${spot[1]}`;
}

function CornerText(props: {
  align: "left" | "right";
  children: string;
}): JSX.Element {
  const { align, children } = props;

  return (
    <Box
      style={{
        position: "relative",
        left: align === "left" ? "2px" : "-2px",
        "text-align": align,
        "text-shadow": "1px 1px 1px #555",
      }}
    >
      {children}
    </Box>
  );
}

export const StripMenu = (props, context) => {
  let { act, data } = useBackend<StripMenuData>(context);

  const gridSpots = new Map<GridSpotKey, string>();
  for (const key of Object.keys(data.items)) {
    gridSpots.set(SLOTS[key].gridSpot, key);
  }

  const grid = [];

  for (let rowIndex = 0; rowIndex < ROWS; rowIndex++) {
    const buttons = [];

    for (let columnIndex = 0; columnIndex < COLUMNS; columnIndex++) {
      const keyAtSpot = gridSpots.get(getGridSpotKey([rowIndex, columnIndex]));
      if (!keyAtSpot) {
        buttons.push(
          <Stack.Item
            style={{
              width: BUTTON_DIMENSIONS,
              height: BUTTON_DIMENSIONS,
            }}
          />
        );
        continue;
      }

      const item = data.items[keyAtSpot];
      const slot = SLOTS[keyAtSpot];

      let alternateAction: AlternateAction | undefined;

      let content;
      let tooltip;

      if (item === null) {
        tooltip = slot.displayName;
      } else if ("name" in item) {
        alternateAction = ALTERNATE_ACTIONS[item.alternate];

        content = (
          <Box
            as="img"
            src={`data:image/jpeg;base64,${item.icon}`}
            height="100%"
            width="100%"
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
              "vertical-align": "middle",
            }}
          />
        );

        tooltip = item.name;
      } else if ("obscured" in item) {
        content = (
          <Icon
            name={
              item.obscured === ObscuringLevel.Completely ? "ban" : "eye-slash"
            }
            size={3}
            ml={0}
            mt={1.3}
            style={{
              "text-align": "center",
              height: "100%",
              width: "100%",
            }}
          />
        );

        tooltip = `obscured ${slot.displayName}`;
      }

      buttons.push(
        <Stack.Item
          style={{
            width: BUTTON_DIMENSIONS,
            height: BUTTON_DIMENSIONS,
          }}
        >
          <Box
            style={{
              position: "relative",
              width: "100%",
              height: "100%",
            }}
          >
            <Button
              onClick={() => {
                act("use", {
                  key: keyAtSpot,
                });
              }}
              fluid
              tooltip={tooltip}
              style={{
                position: "relative",
                width: "100%",
                height: "100%",
                padding: 0,
              }}
            >
              {slot.image && (
                <Box
                  as="img"
                  src={resolveAsset(slot.image)}
                  opacity={0.7}
                  style={{
                    position: "absolute",
                    width: "32px",
                    height: "32px",
                    left: "50%",
                    top: "50%",
                    transform: "translateX(-50%) translateY(-50%) scale(0.8)",
                  }}
                />
              )}

              <Box style={{ position: "relative" }}>{content}</Box>

              {slot.additionalComponent}
            </Button>

            {alternateAction !== undefined && (
              <Button
                onClick={() => {
                  act("alt", {
                    key: keyAtSpot,
                  });
                }}
                tooltip={alternateAction.text}
                style={{
                  background: "rgba(0, 0, 0, 0.6)",
                  position: "absolute",
                  bottom: 0,
                  right: 0,
                  "z-index": 2,
                }}
              >
                <Icon name={alternateAction.icon} />
              </Button>
            )}
          </Box>
        </Stack.Item>
      );
    }

    grid.push(
      <Stack.Item>
        <Stack fill>{buttons}</Stack>
      </Stack.Item>
    );
  }

  return (
    <Window title={`Stripping ${data.name}`} width={400} height={400}>
      <Window.Content>
        <Stack fill vertical>
          {grid}
        </Stack>
      </Window.Content>
    </Window>
  );
};
