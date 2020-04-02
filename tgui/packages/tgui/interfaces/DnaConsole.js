import { toArray } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Divider, Dropdown, Flex, Icon, LabeledList, ProgressBar, Section } from '../components';
import { createLogger } from '../logging';

const logger = createLogger('DnaConsole');

const SUBJECT_CONCIOUS = 0;
const SUBJECT_SOFT_CRIT = 1;
const SUBJECT_UNCONSCIOUS = 2;
const SUBJECT_DEAD = 3;

const GENES = ['A', 'T', 'C', 'G'];
const GENE_COLORS = {
  A: 'green',
  T: 'green',
  G: 'blue',
  C: 'blue',
  X: 'grey',
  '?': 'yellow',
};

const CONSOLE_MODE_STORAGE = 'storage';
const CONSOLE_MODE_SEQUENCER = 'sequencer';
const CONSOLE_MODE_ENZYMES = 'enzymes';
const CONSOLE_MODE_INJECTORS = 'injectors';

const STORAGE_MODE_CONSOLE = 'console';
const STORAGE_MODE_DISK = 'disk';

const STORAGE_SUBMODE_MUTATIONS = 'mutations';
const STORAGE_SUBMODE_CHROMOSOMES = 'chromosomes';
const STORAGE_SUBMODE_GENETICS = 'genetics';

const CHROMOSOME_NEVER = 0;
const CHROMOSOME_NONE = 1;
const CHROMOSOME_USED = 2;

export const DnaConsole = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const {
    consoleMode = CONSOLE_MODE_STORAGE,
  } = data.view;
  return (
    <Fragment>
      <DnaScanner state={state} />
      <DnaConsoleCommands state={state} />
      {consoleMode === CONSOLE_MODE_STORAGE && (
        <DnaConsoleStorage state={state} />
      )}
      {consoleMode === CONSOLE_MODE_SEQUENCER && (
        <DnaConsoleSequencer state={state} />
      )}
    </Fragment>
  );
};

const DnaScanner = props => {
  const { state } = props;
  return (
    <Section
      title="DNA Scanner"
      buttons={(
        <DnaScannerButtons state={state} />
      )}>
      <DnaScannerContent state={state} />
    </Section>
  );
};

const DnaScannerButtons = props => {
  const { data, act } = useBackend(props);
  const {
    hasDelayedAction,
    isPulsingRads,
    isScannerConnected,
    isScrambleReady,
    isViableSubject,
    scannerLocked,
    scannerOpen,
    scrambleSeconds,
  } = data;
  if (!isScannerConnected) {
    return (
      <Button
        content="Connect Scanner"
        onClick={() => act('connect_scanner')} />
    );
  }
  return (
    <Fragment>
      {!!hasDelayedAction && (
        <Button
          content="Cancel Delayed Action"
          onClick={() => act('cancel_delay')} />
      )}
      {!!isViableSubject && (
        <Button
          disabled={!isScrambleReady || isPulsingRads}
          onClick={() => act('scramble_dna')}>
          Scramble DNA
          {!isScrambleReady && ` (${scrambleSeconds}s)`}
        </Button>
      )}
      <Box inline mr={1} />
      <Button
        icon={scannerLocked ? 'lock' : 'lock-open'}
        color={scannerLocked && 'bad'}
        disabled={scannerOpen}
        content={scannerLocked ? 'Locked' : 'Unlocked'}
        onClick={() => act('toggle_lock')} />
      <Button
        disabled={scannerLocked}
        content={scannerOpen ? 'Close' : 'Open'}
        onClick={() => act('toggle_door')} />
    </Fragment>
  );
};

/**
 * Displays subject status based on the value of the status prop.
 */
const SubjectStatus = props => {
  const { status } = props;
  if (status === SUBJECT_CONCIOUS) {
    return (
      <Box inline color="good">Conscious</Box>
    );
  }
  if (status === SUBJECT_UNCONSCIOUS) {
    return (
      <Box inline color="average">Unconscious</Box>
    );
  }
  if (status === SUBJECT_SOFT_CRIT) {
    return (
      <Box inline color="average">Critical</Box>
    );
  }
  if (status === SUBJECT_DEAD) {
    return (
      <Box inline color="bad">Dead</Box>
    );
  }
  return (
    <Box inline>Unknown</Box>
  );
};

const DnaScannerContent = props => {
  const { data, act } = useBackend(props);
  const {
    subjectName,
    isScannerConnected,
    isViableSubject,
    subjectHealth,
    subjectRads,
    subjectStatus,
  } = data;
  if (!isScannerConnected) {
    return (
      <Box color="bad">
        DNA Scanner is not connected.
      </Box>
    );
  }
  if (!isViableSubject) {
    return (
      <Box color="average">
        No viable subject found in DNA Scanner.
      </Box>
    );
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        {subjectName}
        <Icon
          mx={1}
          color="label"
          name="long-arrow-alt-right" />
        <SubjectStatus status={subjectStatus} />
      </LabeledList.Item>
      <LabeledList.Item label="Health">
        <ProgressBar
          value={subjectHealth}
          minValue={0}
          maxValue={100}
          ranges={{
            olive: [101, Infinity],
            good: [70, 101],
            average: [30, 70],
            bad: [-Infinity, 30],
          }}>
          {subjectHealth}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Radiation">
        <ProgressBar
          value={subjectRads}
          minValue={0}
          maxValue={100}
          ranges={{
            bad: [71, Infinity],
            average: [30, 71],
            good: [0, 30],
            olive: [-Infinity, 0],
          }}>
          {subjectRads}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

export const DnaConsoleCommands = props => {
  const { data, act } = useBackend(props);
  const { hasDisk } = data;
  const { consoleMode } = data.view;
  return (
    <Section title="DNA Console">
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            content="Storage"
            selected={consoleMode === CONSOLE_MODE_STORAGE}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_STORAGE,
            })} />
          <Button
            content="Sequencer"
            selected={consoleMode === CONSOLE_MODE_SEQUENCER}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_SEQUENCER,
            })} />
          <Button
            content="Enzymes"
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_ENZYMES,
            })} />
          <Button
            content="Advanced Injectors"
            selected={consoleMode === CONSOLE_MODE_INJECTORS}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_INJECTORS,
            })} />
        </LabeledList.Item>
        {!!hasDisk && (
          <LabeledList.Item label="Disk">
            <Button
              icon="eject"
              content="Eject"
              onClick={() => {
                act('eject_disk');
                act('set_view', {
                  storageMode: STORAGE_MODE_CONSOLE,
                });
              }} />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const StorageButtons = props => {
  const { data, act } = useBackend(props);
  const { hasDisk } = data;
  const { storageMode, storageSubMode } = data.view;
  return (
    <Fragment>
      <Button
        selected={storageSubMode === STORAGE_SUBMODE_MUTATIONS}
        content="Mutations"
        onClick={() => act('set_view', {
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
      <Button
        selected={storageSubMode === STORAGE_SUBMODE_CHROMOSOMES}
        disabled={storageMode !== STORAGE_MODE_CONSOLE}
        content="Chromosomes"
        onClick={() => act('set_view', {
          storageSubMode: STORAGE_SUBMODE_CHROMOSOMES,
        })} />
      <Box inline mr={1} />
      <Button
        content="Console"
        selected={storageMode === STORAGE_MODE_CONSOLE}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_CONSOLE,
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
      <Button
        content="Disk"
        disabled={!hasDisk}
        selected={storageMode === STORAGE_MODE_DISK}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_DISK,
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
    </Fragment>
  );
};

const DnaConsoleStorage = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const { storageSubMode } = data.view;
  return (
    <Section
      title="Storage"
      buttons={(
        <StorageButtons state={state} />
      )}>
      {storageSubMode === STORAGE_SUBMODE_MUTATIONS && (
        <StorageMutations state={state} />
      )}
      {storageSubMode === STORAGE_SUBMODE_CHROMOSOMES && (
        <StorageChromosomes state={state} />
      )}
    </Section>
  );
};

const StorageMutations = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const isDisk = data.view.storageMode === STORAGE_MODE_DISK;
  const mutations = isDisk
    ? toArray(data.diskMutations)
    : toArray(data.mutationStorage);
  const mutationRef = String(data.view.storageMutationRef);
  const mutation = mutations
    .find(mutation => mutation.ByondRef === mutationRef);
  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title={isDisk
            ? "Disk Storage"
            : "Console Storage"}
          level={2}>
          {mutations.map(mutation => (
            <Button
              key={mutation.ByondRef}
              fluid
              ellipsis
              color="transparent"
              selected={mutation.ByondRef === mutationRef}
              content={mutation.Name}
              onClick={() => act('set_view', {
                storageMutationRef: mutation.ByondRef,
              })} />
          ))}
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Divider vertical />
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Section
          title="Mutation Info"
          level={2}>
          <MutationInfo
            state={state}
            mutation={mutation}
            source={isDisk ? 'disk' : 'console'} />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const StorageChromosomes = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const chromos = toArray(data.chromoStorage);
  const chromoName = data.view.storageChromoName;
  const chromo = chromos.find(chromo => chromo.Name === chromoName);
  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title="Console Storage"
          level={2}>
          {chromos.map(chromo => (
            <Button
              key={chromo.Name}
              fluid
              ellipsis
              color="transparent"
              selected={chromo.Name === chromoName}
              content={chromo.Name}
              onClick={() => act('set_view', {
                storageChromoName: chromo.Name,
              })} />
          ))}
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Divider vertical />
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Section
          title="Chromosome Info"
          level={2}>
          {!chromo && (
            <Box color="label">
              Nothing to show.
            </Box>
          ) || (
            <Fragment>
              <LabeledList>
                <LabeledList.Item label="Name">
                  {chromo.Name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {chromo.Description}
                </LabeledList.Item>
              </LabeledList>
              <Button
                mt={2}
                icon="eject"
                content={"Eject Chromosome"}
                onClick={() => act('eject_chromo', {
                  chromo: chromo.Name,
                })} />
            </Fragment>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const MutationInfo = props => {
  const { state, mutation, source } = props;
  const { data, act } = useBackend(props);
  const {
    advInjectors,
    diskCapacity,
    diskReadOnly,
    hasDisk,
    isInjectorReady,
    mutationCapacity,
  } = data;
  const mutationStorage = toArray(data.mutationStorage);
  const diskMutations = toArray(data.diskMutations);
  if (!mutation) {
    return (
      <Box color="label">
        Nothing to show.
      </Box>
    );
  }
  if (source === 'sequencer' && !mutation.Discovered) {
    return (
      <LabeledList>
        <LabeledList.Item label="Name">
          {mutation.Alias}
        </LabeledList.Item>
      </LabeledList>
    );
  }
  const savedToConsole = mutationStorage.find(x => (
    x.Alias === mutation.Alias
  ));
  const savedToDisk = diskMutations.find(x => (
    x.Alias === mutation.Alias
  ));
  return (
    <Fragment>
      <LabeledList>
        <LabeledList.Item label="Name">
          {mutation.Name}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {mutation.Description}
        </LabeledList.Item>
        <LabeledList.Item label="Instability">
          {mutation.Instability}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Dropdown
        width="240px"
        options={advInjectors}
        disabled={advInjectors.length === 0}
        selected="Add to advanced injector"
        onSelected={value => act('add_adv_mut', {
          mutref: mutation.ByondRef,
          advinj: value,
        })} />
      <Button
        icon="syringe"
        disabled={!isInjectorReady}
        content="Print Activator"
        onClick={() => act('print_injector', {
          mutref: mutation.ByondRef,
          is_activator: 1,
          source,
        })} />
      <Button
        icon="syringe"
        disabled={!isInjectorReady}
        content="Print Mutator"
        onClick={() => act('print_injector', {
          mutref: mutation.ByondRef,
          is_activator: 0,
          source,
        })} />
      <br />
      <Button
        icon="save"
        disabled={savedToConsole || mutationCapacity <= 0}
        content="Save to Console"
        onClick={() => act('save_console', {
          mutref: mutation.ByondRef,
          source,
        })} />
      <Button
        icon="save"
        disabled={savedToDisk
          || !hasDisk
          || diskCapacity <= 0
          || diskReadOnly}
        content="Save to Disk"
        onClick={() => act('save_disk', {
          mutref: mutation.ByondRef,
          source,
        })} />
      {['console', 'disk'].includes(source) && (
        <Button
          icon="times"
          color="red"
          content="Delete"
          onClick={() => act(`delete_${source}_mut`, {
            mutref: mutation.ByondRef,
          })} />
      )}
      <Divider />
      <ChromosomeInfo
        state={state}
        mutation={mutation} />
    </Fragment>
  );
};

const ChromosomeInfo = props => {
  const { mutation, disabled } = props;
  const { data, act } = useBackend(props);
  if (mutation.CanChromo === CHROMOSOME_NEVER) {
    return (
      <Box color="label">
        No compatible chromosomes
      </Box>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_NONE) {
    if (disabled) {
      return (
        <Box color="label">
          No chromosome applied.
        </Box>
      );
    }
    return (
      <Fragment>
        <Dropdown
          width="240px"
          options={mutation.ValidStoredChromos}
          disabled={mutation.ValidStoredChromos.length === 0}
          selected={mutation.ValidStoredChromos.length === 0
            ? "No Suitable Chromosomes"
            : "Select a chromosome"}
          onSelected={e => act('apply_chromo', {
            chromo: e,
            mutref: mutation.ByondRef,
          })} />
        <Box color="label" mt={1}>
          Compatible with: {mutation.ValidChromos}
        </Box>
      </Fragment>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_USED) {
    return (
      <Box color="label">
        Applied chromosome: {mutation.AppliedChromo}
      </Box>
    );
  }
  return null;
};

const DnaConsoleSequencer = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const mutations = toArray(data.subjectMutations);
  const {
    isJokerReady,
    isMonkey,
    jokerSeconds,
    subjectStatus,
  } = data;
  const { sequencerMutation, jokerActive } = data.view;
  const mutation = mutations.find(mutation => (
    mutation.Alias === sequencerMutation
  ));
  return (
    <Fragment>
      <Flex spacing={1} mb={1}>
        <Flex.Item width="154px">
          <Section
            title="Genomes"
            minHeight="100%">
            {mutations.map(mutation => (
              <GenomeImage
                key={mutation.Alias}
                url={mutation.Image}
                selected={mutation.Alias === sequencerMutation}
                onClick={() => {
                  act('set_view', {
                    sequencerMutation: mutation.Alias,
                  });
                  act('check_discovery', {
                    alias: mutation.Alias,
                  });
                }} />
            ))}
          </Section>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Section
            title="Genome Info"
            minHeight="100%">
            <MutationInfo
              state={state}
              mutation={mutation}
              source="sequencer" />
          </Section>
        </Flex.Item>
      </Flex>
      {subjectStatus === SUBJECT_DEAD && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: DECEASED.
        </Section>
      ) || (isMonkey && mutation?.Name !== 'Monkified') && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: MONKEY.
        </Section>
      ) || (
        <Section
          title="Genome Sequencer"
          buttons={(
            !isJokerReady && (
              <Box
                lineHeight="20px"
                color="label">
                Joker on cooldown ({jokerSeconds}s)
              </Box>
            ) || jokerActive === 'true' && (
              <Fragment>
                <Box
                  mr={1}
                  inline
                  color="label">
                  Click on a gene to reveal it.
                </Box>
                <Button
                  content="Cancel Joker"
                  onClick={() => act('set_view', {
                    jokerActive: 'false',
                  })} />
              </Fragment>
            ) || (
              <Button
                icon="crown"
                color="purple"
                content="Use Joker"
                onClick={() => act('set_view', {
                  jokerActive: 'true',
                })} />
            )
          )}>
          <GenomeSequencer
            state={state}
            mutation={mutation} />
        </Section>
      )}
    </Fragment>
  );
};

const GenomeImage = props => {
  const { url, selected, onClick } = props;
  let outline;
  if (selected) {
    outline = '2px solid #22aa00';
  }
  return (
    <Box
      as="img"
      src={url}
      style={{
        width: '64px',
        margin: '2px',
        'margin-left': '4px',
        outline,
      }}
      onClick={onClick} />
  );
};

const GeneCycler = props => {
  const { gene, onChange } = props;
  const length = GENES.length;
  const index = GENES.indexOf(gene);
  const color = GENE_COLORS[gene];
  return (
    <Button
      width="22px"
      color={color}
      onClick={e => {
        if (!onChange) {
          return;
        }
        if (e.ctrlKey) {
          onChange('X');
          e.preventDefault();
          return;
        }
        if (e.shiftKey) {
          onChange('?');
          e.preventDefault();
          return;
        }
        const nextGene = GENES[(index + 1) % length];
        onChange(nextGene);
      }}
      oncontextmenu={e => {
        if (!onChange) {
          return;
        }
        e.preventDefault();
        const prevGene = GENES[(index - 1 + length) % length];
        onChange(prevGene);
      }}>
      {gene}
    </Button>
  );
};

const GenomeSequencer = props => {
  const { state, mutation } = props;
  const { data, act } = useBackend(props);
  const { jokerActive } = data.view;
  if (!mutation) {
    return (
      <Box color="average">
        No genome selected for sequencing.
      </Box>
    );
  }
  // Create gene cycler buttons
  const sequence = mutation.Sequence;
  const buttons = [];
  for (let i = 0; i < sequence.length; i++) {
    const gene = sequence.charAt(i);
    const button = (
      <GeneCycler
        gene={gene}
        onChange={nextGene => {
          // We are using true as a string, because currently act()
          // can only send strings. We set this variable in act(),
          // therefore it's also a string.
          if (jokerActive === 'true') {
            act('pulse_gene', {
              pos: i + 1,
              gene: 'J',
              alias: mutation.Alias,
            });
            act('set_view', {
              jokerActive: 'false',
            });
            return;
          }
          act('pulse_gene', {
            pos: i + 1,
            gene: nextGene,
            alias: mutation.Alias,
          });
        }} />
    );
    buttons.push(button);
  }
  // Render genome in two rows
  const pairs = [];
  for (let i = 0; i < buttons.length; i += 2) {
    const pair = (
      <Box
        key={i}
        inline
        m={0.5}
        textAlign="center">
        {buttons[i]}
        <Box mt="-5px" mb="-1px" color="label" content="|" />
        {buttons[i + 1]}
      </Box>
    );
    pairs.push(pair);
  }
  return (
    <Fragment>
      <Box m={-0.5}>
        {pairs}
      </Box>
      <Box color="label" mt={1}>
        <b>Tip:</b> Ctrl+Click on the gene to set it to X.
      </Box>
    </Fragment>
  );
};
