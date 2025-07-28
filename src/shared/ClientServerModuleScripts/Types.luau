export type RewardType = "Ticket" | "SlotUpgrade" -- Add more as needed

export type DailyReward = {
	day: number,
	rewardType: RewardType,
	Amount: number,
}

export type LevelUpReward = {
	level: number,
	rewardType: RewardType,
	Amount: number,
	Stars: number,
}

export type RewardsData = {
	daily: { [string]: DailyReward },
	levelUp: { [string]: LevelUpReward },
}

return {}
