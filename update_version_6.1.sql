ALTER TABLE `t_user_authentication`
DROP INDEX `f_user_id_index` ,
ADD UNIQUE INDEX `f_user_id_index` (`f_user_id`, `f_type`) USING BTREE COMMENT '用户id唯一索引';

ALTER TABLE `t_user`
MODIFY COLUMN `f_leader_status`  int(10) NULL DEFAULT 0 COMMENT '领队状态：0：未邀请、1：已邀请、2：认证待审核、3：已通过认证、4-审核不通过、5-撤销' AFTER `f_emergency_contacts_new`;

ALTER TABLE `t_outing`
MODIFY COLUMN `f_check_state`  int(2) NOT NULL COMMENT '审核状态：0 无需审核，1 未审核，2 审核通过，3-审核不通过，4-草稿' AFTER `f_state`,
MODIFY COLUMN `f_source`  int(2) NOT NULL DEFAULT 0 COMMENT '来源，约伴0，磨房活动1，商业2，俱乐部活动3，领队活动4' AFTER `f_type`;

ALTER TABLE `t_outing_search`
ADD COLUMN `f_check_state`  int(2) NOT NULL DEFAULT 0 COMMENT '审核状态：0 无需审核，1 未审核，2 审核通过，3-审核不通过,4-待提交' AFTER `f_distinct_id`;

ALTER TABLE `t_outing_date`
ADD COLUMN `f_settlement_price`  bigint(20) NULL DEFAULT 0 COMMENT '结算价，单位：分' AFTER `f_zteam_id`;

CREATE TABLE `t_outing_operating_record` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_outing_id` bigint(20) NOT NULL COMMENT '活动基础信息ID',
  `f_system_user_id` bigint(20) NOT NULL COMMENT '后台用户ID',
  `f_type` int(2) NOT NULL COMMENT '操作类型：0-新增，2-修改，3-审核通过，4-审核不通过，5-删除',
  `f_remark` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `f_create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`f_id`),
  KEY `IDX_outing_id` (`f_outing_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动操作记录表';



CREATE TABLE `t_common_user` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `f_sex` tinyint(2) DEFAULT '0' COMMENT '0-未知，1-男，2-女',
  `f_birthday` date DEFAULT NULL COMMENT '生日',
  `f_contact_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `f_contact_area_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话的区号',
  `f_cert_type` tinyint(2) DEFAULT NULL COMMENT '证件类型（1-身份证，2-护照，3-港澳通行证）',
  `f_cert_code` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '证件号',
  `f_user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `f_isdeleted` tinyint(2) DEFAULT '0' COMMENT '是否删除 0未删除 1已删除',
  PRIMARY KEY (`f_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='常用报名人信息';




CREATE TABLE `t_business_activity_order` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_member_id` bigint(20) DEFAULT NULL COMMENT '成员id',
  `f_outing_id` bigint(20) NOT NULL COMMENT '活动基础信息ID',
  `f_user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `f_outing_date_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '活动团期ID',
  `f_status` int(2) NOT NULL DEFAULT '0' COMMENT '订单状态：0-未支付，1-支付成功，2-支付失败，3-退款中，4-退款成功，5-退款失败,6-订单已取消',
  `f_apply_status` int(2) NOT NULL DEFAULT '0' COMMENT '报名状态：1-待确认，2-已确认，3-取消报名（超时自动取消），4-取消报名（用户主动取消），5-已拒绝',
  `f_pay_type` int(2) DEFAULT '0' COMMENT '支付方式：0-全为零钱支付，1-支付宝，2-微信',
  `f_pay_order_num` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '支付订单号',
  `f_cash` bigint(20) DEFAULT '0' COMMENT '现金（分）',
  `f_can_withdraw_money` bigint(20) DEFAULT '0' COMMENT '可提现零钱(分)',
  `f_cannot_withdraw_money` bigint(20) DEFAULT '0' COMMENT '不可提现零钱（分）',
  `f_currency` int(11) DEFAULT '0' COMMENT '虚拟币（绿豆）',
  `f_compensation_money` bigint(20) DEFAULT '0' COMMENT '补尝金（零钱，分）',
  `f_back_cash` bigint(20) DEFAULT '0' COMMENT '退款现金部分（分）',
  `f_back_can_withdraw_money` bigint(20) DEFAULT '0' COMMENT '退款可提现零钱部分(分)',
  `f_back_cannot_withdraw_money` bigint(20) DEFAULT '0' COMMENT '退款不可提现零钱部分(分)',
  `f_create_time` datetime NOT NULL COMMENT '创建时间',
  `f_update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `f_pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `f_damage` bigint(20) NOT NULL DEFAULT '0' COMMENT '违约金',
  `f_msg` varchar(512) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '描述信息',
  `f_remark` varchar(512) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '后台备注',
  `f_flag` int(2) DEFAULT '0' COMMENT '补偿金发放状态：0-不发放，1-等待发放，2-已发放',
  `f_terminal_type` int(2) DEFAULT '1' COMMENT '终端类型： 1-web ，2-android， 3-iphone',
  `f_last_compensation_date_id` bigint(20) DEFAULT '0' COMMENT '最后一个赔偿的团期ID',
  `f_total_fee` bigint(20) DEFAULT NULL COMMENT '订单总额',
  PRIMARY KEY (`f_id`),
  KEY `Uniq_outing_id_user_id` (`f_outing_id`,`f_user_id`,`f_outing_date_id`),
  KEY `IDX_outing_id` (`f_outing_id`),
  KEY `IDX_user_id` (`f_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商业活动订单信息';



CREATE TABLE `t_business_activity_member` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_outing_id` bigint(20) NOT NULL COMMENT '活动基础信息ID',
  `f_check_state` int(2) NOT NULL DEFAULT '0' COMMENT '审核状态，待审核0，通过1，拒绝2',
  `f_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '活动资料中的姓名',
  `f_sex` int(2) DEFAULT '0' COMMENT '''性别：0-未知 1-男 2-女''',
  `f_contact_area_code` varchar(20) CHARACTER SET utf8mb4 DEFAULT '86' COMMENT '联系电话的区号',
  `f_contact_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `f_join_time` datetime DEFAULT NULL COMMENT '加入活动时间',
  `f_insurance_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '险种',
  `f_insurance_num` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '保险单号',
  `f_insurance_company` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '保险公司',
  `f_create_time` datetime NOT NULL COMMENT '创建时间',
  `f_update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `f_terminal_type` int(2) DEFAULT NULL COMMENT '1-web 2-android 3-iphone',
  `f_gather_site_id` bigint(20) DEFAULT NULL COMMENT '集合点',
  `f_refuse_content` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝理由',
  `f_outing_date_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '活动团期ID',
  `f_status` int(2) NOT NULL DEFAULT '0' COMMENT '状态：0-正常，1-已迁移，2-已取消，3-已取消-违约',
  `f_target_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '迁移的目标团期ID',
  `f_special_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '特殊说明',
  `f_cert_type` int(2) DEFAULT NULL COMMENT '1-身份证，2-护照，3-港澳通行证',
  `f_cert_code` varchar(64) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '证件号',
  `f_birthday` date DEFAULT NULL COMMENT '生日',
  `f_order_id` bigint(20) DEFAULT NULL COMMENT '订单ID',
  `f_isdeleted` tinyint(1) DEFAULT '0' COMMENT '是否删除 0未删除 1已删除',
  `f_currency` bigint(20) DEFAULT NULL COMMENT '绿豆',
  `f_cash` bigint(20) DEFAULT NULL,
  `f_can_withdraw_money` bigint(20) DEFAULT NULL,
  `f_cannot_withdraw_money` bigint(20) DEFAULT NULL,
  `f_back_currency` bigint(20) DEFAULT NULL,
  `f_back_cash` bigint(20) DEFAULT NULL COMMENT '退还现金（分）',
  `f_back_can_withdraw_money` bigint(20) DEFAULT NULL COMMENT '退还可提现零钱（分）',
  `f_back_cannot_withdraw_money` bigint(20) DEFAULT NULL COMMENT '退还不可提现零钱（分）',
  `f_refund_serial_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `f_fee` bigint(255) DEFAULT NULL COMMENT '报名费总额',
  PRIMARY KEY (`f_id`),
  KEY `IDX_outing_id` (`f_outing_id`),
  KEY `IDX_order_id` (`f_order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商业活动成员基础信息';



CREATE TABLE `t_income_record` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `f_leader_type` int(2) NOT NULL COMMENT '领队类型：1-领队，2-俱乐部',
  `f_type` int(2) NOT NULL COMMENT '操作类型：1-收入，2-支出',
  `f_title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标题',
  `f_remark` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `f_amount` bigint(20) NOT NULL COMMENT '金额（单位：分）',
  `f_order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `f_order_member_ids` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '影响到的订单成员ID，以,分隔',
  `f_create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`f_id`),
  KEY `IDX_user_id` (`f_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收入记录';

ALTER TABLE `t_user_authentication`
ADD COLUMN `f_income`  bigint(20) NOT NULL DEFAULT 0 COMMENT '收入，单位：分' AFTER `f_is_update`;

-- t_business_activity_order表添加索引
ALTER TABLE `t_business_activity_order`
ADD INDEX `IDX_outing_date_id` (`f_outing_date_id`) USING BTREE ;

-- t_business_activity_order表修改字段t_total_fee类型
ALTER TABLE `t_business_activity_order`
MODIFY COLUMN `f_total_fee`  bigint(20) NOT NULL DEFAULT 0 COMMENT '订单总额' AFTER `f_last_compensation_date_id`;

ALTER TABLE `t_outing_order_statistics`
ADD COLUMN `f_outing_source`  int(2) NOT NULL DEFAULT 2 COMMENT '活动类型：2-自营活动，3-俱乐部活动，4-领队活动' AFTER `f_update_time`,
ADD COLUMN `f_member_order_num`  int NOT NULL DEFAULT 0 COMMENT '报名订单数' AFTER `f_outing_source`;

ALTER TABLE `t_outing_order_statistics`
ADD UNIQUE INDEX `idx_userId_source` (`f_user_id`, `f_outing_source`) ;

ALTER TABLE `t_outing_date`
ADD COLUMN `f_is_deleted`  int(2) NOT NULL DEFAULT 0 COMMENT '是否删除：0正常,1删除' AFTER `f_check_state`;

ALTER TABLE `t_outing`
MODIFY COLUMN `f_check_state`  int(2) NOT NULL COMMENT '审核状态：0 无需审核，1 未审核，2 审核通过，3-审核不通过,4-待提交(草稿)' AFTER `f_state`;

CREATE TABLE `t_business_activity_order_item` (
  `f_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `f_member_order_id` bigint(20) DEFAULT NULL COMMENT '成员报名订单ID',
  `f_user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `f_outing_date_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '活动团期ID',
  `f_type` int(2) DEFAULT '0' COMMENT '类型：1-支付，2-退回',
  `f_money_type` int(2) DEFAULT NULL COMMENT '钱的类型：1-现金，2-不可提现零钱，3-可提现零钱，4-绿豆',
  `f_pay_order_num` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '支付订单号',
  `f_amount` bigint(20) DEFAULT '0' COMMENT '现金和零钱时，单位为分，绿豆时为个',
  `f_msg` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '说明',
  `f_create_time` datetime NOT NULL COMMENT '创建时间',
  `f_update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`f_id`),
  KEY `Uniq_outing_id_user_id` (`f_user_id`),
  KEY `IDX_order_id` (`f_member_order_id`),
  KEY `IDX_user_id` (`f_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='活动订单明细';

INSERT INTO t_business_activity_order_item SELECT * FROM t_outing_member_order_item;
DELETE FROM routedb WHERE `name` = 't_business_activity_order_item';
INSERT INTO routedb SELECT 't_business_activity_order_item' as `name`, id, NOW() FROM routedb WHERE `name` = 't_outing_member_order_item';

ALTER TABLE `t_outing_date`
MODIFY COLUMN `f_update_time`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `f_create_time`;
