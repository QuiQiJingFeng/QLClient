return {
    behavior = {
        ["10002"] = {
            HALL = { -- key = 入口 ， value = behavior数组
                "FRIENDS|||NODE", -- 渠道+形式，中间由|||分隔
                "MOMENTS|||NODE",
            },
            ROOM_INFO = {
                "SYSTEM|||NODE",
            },
			OFFLINE_ROOM_INFO = {
                "SYSTEM|||NODE",
            },
			CLUB_ROOM_INFO = {
                "SYSTEM|||NODE",
				"DINGDING|||NODE",
            },
            FINAL_REPORT = {
                "SYSTEM|||SCREEN_SHOT",
            },
            TIMEOUT = {
                "SYSTEM|||SCREEN_SHOT",
				"DINGDING|||SCREEN_SHOT",
            },
            REPLAY = {
                "SYSTEM|||NODE",
				"DINGDING|||NODE",
            },
            CAMPAIGN = {
                "FRIENDS|||NODE",
                "MOMENTS|||NODE",
            },
            CLUB_RED_ACTIVITY = {
                "FRIENDS|||SCREEN_SHOT_WITH_LOGO",
                "MOMENTS|||SCREEN_SHOT_WITH_LOGO",
            },
            CLUB_REWARD_ACTIVITY = {
                "FRIENDS|||SCREEN_SHOT_WITH_LOGO",
                "MOMENTS|||SCREEN_SHOT_WITH_LOGO",
            },
            SHARE_RECALL = {
                "FRIENDS|||URL",
                "MOMENTS|||URL",
            },
            MONEY_TREE = {
                "FRIENDS|||SCREEN_SHOT",
				"MOMENTS|||SCREEN_SHOT",
            },
            DAILY_SHARE = {
                "FRIENDS|||SCREEN_SHOT",
				"MOMENTS|||SCREEN_SHOT",
            },
            SHARE_GET_GOLD_ANDROID = {
                "FRIENDS|||NODE",
				"MOMENTS|||NODE",
            },
            SHARE_GET_GOLD_IOS = {
                "FRIENDS|||SHORT_URL",
				"MOMENTS|||SHORT_URL",
            },
            TURN_CARD_SHARE = {
                "FRIENDS|||NODE",
                "MOMENTS|||NODE",
            },
            TURN_CARD_ITEM_SHARE = {
                "FRIENDS|||SCREEN_SHOT_WITH_LOGO",
                "MOMENTS|||SCREEN_SHOT_WITH_LOGO",
            },
            SYSTEM_SCREEN_SHOT = {
                "FRIENDS|||SCREEN_SHOT",
				"MOMENTS|||SCREEN_SHOT",
            },
            SHARE_PULLNEW = {
                "FRIENDS|||NODE_WITH_QRCODE",
            },
            WEEK_SIGN = {
                "FRIENDS|||SCREEN_SHOT_WITH_LOGO",
				"MOMENTS|||SCREEN_SHOT_WITH_LOGO",
            },
            NEW_SHARE_FRIEND = {
                "FRIENDS|||NODE",
            },
            NEW_SHARE_CIRCLE = {
                "MOMENTS|||NODE",
            },
			CLUB_INVITED_FRIENDS = {
                "FRIENDS|||URL",    
            },
			CLUB_INVITED_MOMENTS = {
                "MOMENTS|||URL",
            },
			LEADER_BOARD_SHARE = {
                "FRIENDS|||NODE",
			},
            COMEBACK = {
                "FRIENDS|||NODE_WITH_QRCODE"
            },
			ACTIVITY_FOR_SCREEN_SHOT = {
				"FRIENDS|||NODE"
			},
            OPEN_REDPACKAGE = {
                "FRIENDS|||URL",
            },
			SPRING_INVITED = {
                "FRIENDS|||NODE_WITH_QRCODE",
            },
			SHARE_COLLECTION = {
                "MOMENTS|||NODE",
			},
            COLLECT_CODE = {
                "FRIENDS|||SCREEN_SHOT_WITH_LOGO"
            },
            NIAN_BAO = {
                "FRIENDS|||URL"
            }
        },
        ["20001"] = {
            HALL = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            ROOM_INFO = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            FINAL_REPORT = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            CAMPAIGN = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            TIMEOUT = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            TURN_CARD_SHARE = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            },
            TURN_CARD_ITEM_SHARE = {
                "CHAO_SHAN|||USE_SYSTEM_FIRST"
            }
        }
    },
    shortUrls = {
        -- 贵阳
        ["10002"] = {
            -- 默认
            default = "https://lnk0.com/easylink/ELABxpso",
            -- 大厅
            HALL_FRIENDS = "https://lnk0.com/easylink/ELRFNdc0",
            HALL_MOMENTS = "https://lnk0.com/easylink/ELABxpso",
            HALL_SYSTEM = "https://lnk0.com/easylink/ELFxxh4g",
            -- 房间规则
            ROOM_INFO_FRIENDS = "https://lnk0.com/easylink/EL4g8MZ1",
            ROOM_INFO_MOMENTS = "https://lnk0.com/easylink/EL8oItcg",
            ROOM_INFO_SYSTEM = "https://lnk0.com/easylink/ELpkAtwp",
            -- 每日分享
            DAILY_SHARE_SYSTEM = "https://lnk0.com/easylink/ELUp0sIl",

            SHARE_GET_GOLD_IOS_FRIENDS = "https://lnk0.com/easylink/ELRFNdc0",
        }
    },
    shareImagesPath = {
        -- 贵阳
        ["10002"] = "art/share/guiyang", -- 文件路径
        ["20001"] = "art/share/chaoshan" -- 文件路径
    }
}