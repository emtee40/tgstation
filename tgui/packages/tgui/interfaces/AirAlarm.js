import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { Scrubber, Vent } from './common/AtmosControls';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const AirAlarm = (_, context) => {
	const { data } = useBackend(context);
	const locked = data.locked && !data.siliconUser;

	return (
		<Window width={440} height={650}>
			<Window.Content scrollable>
				<InterfaceLockNoticeBox />
				<AirAlarmStatus />
				{!locked && <AirAlarmControl />}
			</Window.Content>
		</Window>
	);
};

const AirAlarmStatus = (_, context) => {
	const { data } = useBackend(context);
	const entries = (data.environment_data || []).filter(
		(entry) => entry.value >= 0.01
	);
	const dangerMap = {
		0: {
			color: 'good',
			localStatusText: 'Optimal',
		},
		1: {
			color: 'average',
			localStatusText: 'Caution',
		},
		2: {
			color: 'bad',
			localStatusText: 'Danger (Internals Required)',
		},
	};
	const localStatus = dangerMap[data.danger_level] || dangerMap[0];

	return (
		<Section title="Air Status">
			<LabeledList>
				{(entries.length > 0 && (
					<>
						{entries.map((entry) => {
							const status = dangerMap[entry.danger_level] || dangerMap[0];
							return (
								<LabeledList.Item
									key={entry.name}
									label={entry.name}
									color={status.color}>
									{toFixed(entry.value, 2)}
									{entry.unit}
								</LabeledList.Item>
							);
						})}
						<LabeledList.Item label="Local status" color={localStatus.color}>
							{localStatus.localStatusText}
						</LabeledList.Item>
						<LabeledList.Item
							label="Area status"
							color={data.atmos_alarm || data.fire_alarm ? 'bad' : 'good'}>
							{(data.atmos_alarm && 'Atmosphere Alarm') ||
								(data.fire_alarm && 'Fire Alarm') ||
								'Nominal'}
						</LabeledList.Item>
					</>
				)) || (
					<LabeledList.Item label="Warning" color="bad">
						Cannot obtain air sample for analysis.
					</LabeledList.Item>
				)}
				{!!data.emagged && (
					<LabeledList.Item label="Warning" color="bad">
						Safety measures offline. Device may exhibit abnormal behavior.
					</LabeledList.Item>
				)}
			</LabeledList>
		</Section>
	);
};

const AIR_ALARM_ROUTES = {
	home: {
		title: 'Air Controls',
		component: () => AirAlarmControlHome,
	},
	vents: {
		title: 'Vent Controls',
		component: () => AirAlarmControlVents,
	},
	scrubbers: {
		title: 'Scrubber Controls',
		component: () => AirAlarmControlScrubbers,
	},
	modes: {
		title: 'Operating Mode',
		component: () => AirAlarmControlModes,
	},
	thresholds: {
		title: 'Alarm Thresholds',
		component: () => AirAlarmControlThresholds,
	},
};

const AirAlarmControl = (_, context) => {
	const [screen, setScreen] = useLocalState(context, 'screen');
	const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
	const Component = route.component();

	return (
		<Section
			title={route.title}
			buttons={
				screen && (
					<Button
						icon="arrow-left"
						content="Back"
						onClick={() => setScreen()}
					/>
				)
			}>
			<Component />
		</Section>
	);
};

//  Home screen
// --------------------------------------------------------

const AirAlarmControlHome = (_, context) => {
	const { act, data } = useBackend(context);
	// eslint-disable-next-line no-unused-vars
	const [screen, setScreen] = useLocalState(context, 'screen');
	const { mode, atmos_alarm } = data;

	return (
		<>
			<Button
				icon={atmos_alarm ? 'exclamation-triangle' : 'exclamation'}
				color={atmos_alarm && 'caution'}
				content="Area Atmosphere Alarm"
				onClick={() => act(atmos_alarm ? 'reset' : 'alarm')}
			/>
			<Box mt={1} />
			<Button
				icon={mode === 3 ? 'exclamation-triangle' : 'exclamation'}
				color={mode === 3 && 'danger'}
				content="Panic Siphon"
				onClick={() =>
					act('mode', {
						mode: mode === 3 ? 1 : 3,
					})
				}
			/>
			<Box mt={2} />
			<Button
				icon="sign-out-alt"
				content="Vent Controls"
				onClick={() => setScreen('vents')}
			/>
			<Box mt={1} />
			<Button
				icon="filter"
				content="Scrubber Controls"
				onClick={() => setScreen('scrubbers')}
			/>
			<Box mt={1} />
			<Button
				icon="cog"
				content="Operating Mode"
				onClick={() => setScreen('modes')}
			/>
			<Box mt={1} />
			<Button
				icon="chart-bar"
				content="Alarm Thresholds"
				onClick={() => setScreen('thresholds')}
			/>
		</>
	);
};

//  Vents
// --------------------------------------------------------

const AirAlarmControlVents = (_, context) => {
	const { data } = useBackend(context);
	const { vents } = data;

	if (!vents || vents.length === 0) {
		return 'Nothing to show';
	}
	return vents.map((vent) => <Vent key={vent.id_tag} vent={vent} />);
};

//  Scrubbers
// --------------------------------------------------------

const AirAlarmControlScrubbers = (_, context) => {
	const { data } = useBackend(context);
	const { scrubbers } = data;

	if (!scrubbers || scrubbers.length === 0) {
		return 'Nothing to show';
	}
	return scrubbers.map((scrubber) => (
		<Scrubber key={scrubber.id_tag} scrubber={scrubber} />
	));
};

//  Modes
// --------------------------------------------------------

const AirAlarmControlModes = (_, context) => {
	const { act, data } = useBackend(context);
	const { modes } = data;

	if (!modes || modes.length === 0) {
		return 'Nothing to show';
	}
	return modes.map((mode) => (
		<Fragment key={mode.mode}>
			<Button
				icon={mode.selected ? 'check-square-o' : 'square-o'}
				selected={mode.selected}
				color={mode.selected && mode.danger && 'danger'}
				content={mode.name}
				onClick={() => act('mode', { mode: mode.mode })}
			/>
			<Box mt={1} />
		</Fragment>
	));
};

//  Thresholds
// --------------------------------------------------------

const AirAlarmControlThresholds = (_, context) => {
	const { act, data } = useBackend(context);
	const { thresholds } = data;

	return (
		<table className="LabeledList" style={{ width: '100%' }}>
			<thead>
				<tr>
					<td />
					<td className="color-bad">hazard_min</td>
					<td className="color-average">warning_min</td>
					<td className="color-average">warning_max</td>
					<td className="color-bad">hazard_max</td>
				</tr>
			</thead>
			<tbody>
				{thresholds.map((threshold) => (
					<tr key={threshold.name}>
						<td className="LabeledList__label">{threshold.name}</td>
						{threshold.settings.map((setting) => (
							<td key={setting.val}>
								<Button
									content={toFixed(setting.selected, 2)}
									onClick={() =>
										act('threshold', {
											env: setting.env,
											var: setting.val,
										})
									}
								/>
							</td>
						))}
					</tr>
				))}
			</tbody>
		</table>
	);
};
