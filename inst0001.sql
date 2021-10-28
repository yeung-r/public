CREATE DATABASE InstDB

CREATE TABLE `user` (
  `userID` int(5) NOT NULL,
  `f_name` varchar(40) NOT NULL,
  `l_name` varchar(40) NOT NULL,
  `email` varchar(40) NOT NULL,
  `phone_no` int(15) NOT NULL,
  `rating` int(1) NOT NULL,
  `username` varchar(40) NOT NULL,
  `password` varchar(40) NOT NULL,
  PRIMARY KEY (userID)
);

INSERT INTO `user` (`user_Id`, `f_name`, `l_name`, `email`, `phone_no`, `rating`, `username`, `password`) VALUES
(1, 'Miyah', 'Carter', 'miyah@inst.com', 6042326945, 3, 'miyah_carter', 'mc6042326945'),
(2, 'Nasir', 'Greenaway', 'nasir@inst.com', 2865840083, 3, 'nasir_greenway', 'ng2865840083'),
(3, 'Lauren', 'Lennon', 'lauren@inst.com', 7578168076, 3, 'lauren_lennon', 'll7578168076'),
(4, 'Atlas', 'Sullivan', 'atlas@inst.com', 3483042961, 3, 'atlas_sullivan', 'as3483042961'),
(5, 'Oliver', 'Thomson', 'oliver@inst.com', 4117724837, 3, 'oliver_thomson', 'ot4117724837'),
(6, 'Orion', 'Howell', 'orion@inst.com', 7640464631, 3, 'orion_howell', 'oh7640464631'),
(7, 'Letitia', 'Harrison', 'letitia@inst.com', 7800155318, 3, 'letitia_harrison', 'lr7800155318'),
(8, 'Jake', 'Calvert', 'jake@inst.com', 4760112741, 3, 'jake_calvert', 'jc4760112741'),
(9, 'Seb', 'Wood', 'seb@inst.com', 5505536262, 3, 'seb_wood', 'sw5505536262'),
(10, 'Rachel', 'Summers', 'rachel@inst.com', 6366815331, 3, 'rachel_summers', 'rs6366815331');

CREATE DATABASE InstDB;

CREATE TABLE `user` (
    `userID` int(5) NOT NULL,
    `f_name` varchar(40) NOT NULL,
    `l_name` varchar(40) NOT NULL,
    `email` varchar(40) NOT NULL,
    `phone_no` varchar(20) NOT NULL,
    `rating` int(1) NOT NULL,
    `username` varchar(40) NOT NULL,
    `password` varchar(40) NOT NULL,
    PRIMARY KEY (`userID`)
);

INSERT INTO `users` (`user_id`, `f_name`, `l_name`, `email`, `phone_no`, `ratings`, `username`, `password`) VALUES
(1, 'Arnold', 'Nash', 'arnold@inst.com', 5293485295, , 'arnold_nash', 'an5293485295'),
(2, 'Miyah', 'Carter', 'miyah@inst.com', 6042326945, 3, 'miyah_carter', 'mc6042326945'),
(3, 'Nasir', 'Greenaway', 'nasir@inst.com', 2865840083, 3, 'nasir_greenway', 'ng2865840083'),
(4, 'Lauren', 'Lennon', 'lauren@inst.com', 7578168076, 3, 'lauren_lennon', 'll7578168076'),
(5, 'Atlas', 'Sullivan', 'atlas@inst.com', 3483042961, 3, 'atlas_sullivan', 'as3483042961'),
(6, 'Oliver', 'Thomson', 'oliver@inst.com', 4117724837, 3, 'oliver_thomson', 'ot4117724837'),
(7, 'Orion', 'Howell', 'orion@inst.com', 7640464631, 3, 'orion_howell', 'oh7640464631'),
(8, 'Letitia', 'Harrison', 'letitia@inst.com', 7800155318, 3, 'letitia_harrison', 'lr7800155318'),
(9, 'Jake', 'Calvert', 'jake@inst.com', 4760112741, 3, 'jake_calvert', 'jc4760112741'),
(10, 'Seb', 'Wood', 'seb@inst.com', 5505536262, 3, 'seb_wood', 'sw5505536262'),
(11, 'Rachel', 'Summers', 'rachel@inst.com', 6366815331, 3, 'rachel_summers', 'rs6366815331');

INSERT INTO `items` (`item_id`, `item_type`, `item_description`, `seller_id`, `buyer_id`, `closing_date`, `starting_price`, `current_bid`, `commission`, `address_id`) VALUES
(1, 'Scarf', 'Blue, Checkered', 5, 7, '2021-03-06', 11.00, 19.00, 0.57, 5),
(2,'Shoe', 'Formal, 7', 8 , 9, '2021-03-07', 15.00, 21.00, 0.63, 9),
(3, 'Bottle', 'Clear, 500', 3, 3, '2021-03-11', 4.80, 9.00, 0.27, 3),
(4, 'Shoe', 'Sports, 8', 11, 7, '2021-03-13', 13.50, 15.00, 0.45, 14),
(5, 'Shoe', 'Casual, 8', 2, 10, '2021-03-16', 12.60, 19.50, 0.59, 1),
(6, 'Shoe', 'Casual, 8', 3, 6, '2021-03-18', 14.20, 21.00, 0.63, 2),
(7, 'Scarf', 'Yellow, Striped', 6, 3, '2021-03-19', 8.50, 11.00, 0.33, 6),
(8, 'Bottle', 'Blue, 750', 11, 9, '2021-03-20', 9.70, 10.50, 0.32, 13),
(9, 'Bottle', 'Clear, 1200', 4, 10, '2021-03-21', 5.50, 8.00, 0.24, 4),
(10, 'Scarf', 'Red, Plain', 8, 9, '2021-03-23', 12.00, 15.60, 0.47, 9),
(11,'Scarf','Green, Plain', 2, 6, '2021-03-24', 11.00, 14.70, 0.44, 1),
(12, 'Shoe', 'Sports, 11', 5, 6, '2021-03-25', 21.00, 27.00, 0.81, 5),
(13, 'Shoe', 'Formal, 9', 11, 7, '2021-03-27', 25.00, 31.50, 0.95, 14),
(14, 'Shoe', 'Casual, 10', 6, 3, '2021-03-28', 18.00, 24.70, 0.74, 6),
(15, 'Bottle', 'Yellow, 600', 3, 10, '2021-04-03', 7.80, 13.30, 0.40, 3),
(16, 'Scarf', 'Purple, Checkered', 8, 7, '2021-04-05', 12.40, 15.40, 0.46, 9),
(17, 'Scarf', 'Blue, Striped', 11, 9, '2021-04-06', 14.00, 16.00, 0.48, 13),
(18, 'Shoe', 'Formal, 9', 6, 10, '2021-04-08', 13.50, 17.30, 0.52, 6),
(19, 'Bottle', 'Clear, 1000', 3, 3, '2021-04-10', 6.00, 8.00, 0.24, 2),
(20, 'Scarf', 'Pink, Striped', 2, 6, '2021-04-12', 11.50, 14.00, 0.42, 1);


CREATE TABLE `Item` (
  `ItemID` int(5) NOT NULL,
  `ItemType` varchar(40) NOT NULL,
  `ItemDescription` varchar(255) NOT NULL,
  `SellerID` int(5) NOT NULL,
  `BuyerID` int(5) NOT NULL,
  `AddressID` date NOT NULL,
  `ClosingDate` date NOT NULL,
  `CurrentBid` decimal(7,2) NOT NULL DEFAULT '0.00',
  `Commission` decimal(7,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `items`(
    `item_id` INT NOT NULL,
    `item_type` VARCHAR(40) NOT NULL,
    `item_description` VARCHAR(80),
    `seller_id` INT NOT NULL,
    `buyer_id` INT NOT NULL,
    `closing_date` DATE NOT NULL,
    `starting_price` DECIMAL(7, 2) NOT NULL,
    `current_bid` DECIMAL(7, 2) NOT NULL,
    `commission` DECIMAL(7, 2) NOT NULL,
    `address_id` INT NOT NULL,
    PRIMARY KEY(item_id),
    FOREIGN KEY(seller_id) REFERENCES users(user_id),
    FOREIGN KEY(buyer_id) REFERENCES users(user_id),
    FOREIGN KEY(address_id) REFERENCES address(address_id)
);

SELECT
    `users`.`f_name` AS 'first name',
    `users`.`l_name` AS 'last name',
    `items`.`item_type` AS 'item type',
    `items`.`item_description` AS 'item description',
    `items`.`current_bid` AS 'sale price'
FROM
    `users`
INNER JOIN `items` ON `users`.`user_id` = `items`.`seller_id`;

SELECT `seller_id`, COUNT(`seller_id`) AS `seller_occurence`, `f_name` AS 'first name', ` l_name` AS 'last name', `item_type` AS 'item type', ` item_description` AS 'item description', ` current_bid` AS 'sale price' FROM `users` JOIN `items` ON `users`.`user_id` = `items`.`seller_id` GROUP BY `seller_id` ORDER BY `seller_occurence` DESC LIMIT  1


SELECT SUM(`current_bid`) AS 'march sale', SUM(`commission`) AS 'total commission' FROM `items` WHERE `closing_date` LIKE '2021-03%';

SELECT `item_type` AS 'item type', COUNT(`item_type`) AS 'item occurrence' FROM `items` GROUP BY `item_type` ORDER BY `item occurrence` DESC LIMIT 1

SELECT `item_type` AS 'item type', `item_description` AS 'item_description', `closing_date` AS 'closing date', `city`, `current_bid` AS 'bid audit' FROM `items` JOIN `address` ON `items`.`address_id` = `address`.`address_id` WHERE DATEDIFF('2021-04-12', 

SELECT `f_name` AS 'first name', `l_name` AS 'last name', `item_type` AS 'item sold', `commission`, SUM(`current_bid`) AS 'grand total' FROM `users` JOIN `items` ON `users`.`user_id` = `items`.`seller_id` WHERE `closing_date` LIKE '2021-03%'


SELECT `f_name` AS 'first name',
       `l_name` AS 'last name',
       `item_type` AS 'item type',
       `item_description` AS 'item_description',
       `current_bid` AS 'sale price',
       count(*)
FROM `users` JOIN `items`
ON `users`.`user_id` = `items`.`seller_id`
GROUP BY `item_type` AND `current_bid`
HAVING count(*) =
  (SELECT MAX(mycount)
   FROM
     (SELECT COUNT(*) mycount
      FROM items
      GROUP BY seller_id) a);


-- in an invoice, we need
-- first name, last name, item type, commission, commission grand total


SELECT
    TOP 1 `seller_id`,
    COUNT(`seller_id`) AS 'MAX_COUNT',
    `f_name` AS 'first name',
    `l_name` AS 'last name',
    `item_type` AS 'item sold',
    `item_description` AS 'item description',
    `commission`,
    SUM(`commission`) AS 'commission grand total'
FROM
    `items` JOIN `users` ON `items`.`seller_id`=`users`.`user_id`
GROUP BY
    `seller_id`
ORDER BY
    'MAX_COUNT'
DESC
WHERE `closing_date` LIKE '2021-03%'
;