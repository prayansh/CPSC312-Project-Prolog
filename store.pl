% This is the knowledge base for the store domain

% store constants
door(pos(0,0)).
exit(pos(5,5)).
sizeX(5).
sizeY(5).

prop(apple, name, "Apple").
prop(apple, weight, 10).
prop(apple, price, 2).

prop(banana, name, "Banana").
prop(banana, weight, 10).
prop(banana, price, 3).

prop(carrot, name, "Carrot").
prop(carrot, weight, 20).
prop(carrot, price, 5).

prop(date, name, "Date").
prop(date, weight, 30).
prop(date, price, 2).

% shelf(id, product)
shelf(s1, apple).
shelf(s2, banana).
shelf(s3, carrot).
shelf(s4, date).
shelf(s5, apple).
shelf(s6, carrot).

% basket(id)
basket(b1).
basket(b2).

% predicates
item(N, W, P) :- prop(X, name, N), prop(X, weight, W), prop(X, price, P).

mat_id(ID):- basket(ID).
mat_id(ID):- shelf(ID, _).

% shelf_item_count(time, id, item name, number) : gets the number N of items with name IN in shelf with id ID at time T
shelf_item_count(T, ID, IN, N):- in_scope(T), prop(I, name, IN), shelf(ID, I),  measurement(ID, W, T, _), prop(I, weight, IW),  N is (W / IW), prop(I, name, IN).

% store_item_count(time, item name, number) : gets the number N of items with name IN remaining in the shelfs at time T
store_item_count(T, IN, N):- in_scope(T), prop(_, name, IN), findall(SN, shelf_item_count(T, _, IN, SN), L), sumlist(L, N).

% calc_price(item, number, price): calculates the price P of N items of item I
calc_price(I, N, P):- prop(I, price, IP), P is (IP*N).

% basket_price(time, basket id, price): get the price P of all items in basket with id ID at time T
basket_price(T, ID, P):- in_scope(T), basket(ID), findall(IP, (basket_has(T, ID, IN, N), prop(I, name, IN), calc_price(I, N, IP)), L), sumlist(L, P).

% basket_has(T, BID, IN, N) is true if at time T the basket with mat_id BID has N number of item with name IN
basket_has(T, BID, IN, N) :- in_scope(T), basket(BID), prop(_, name, IN), findall(N0, basket_has_helper(T, BID, IN, N0), L), sumlist(L, N), N>0.
basket_has_helper(T, BID, IN, N) :- in_scope(T), grabbed(T0, BID, _, IN, N), T0 =< T.
basket_has_helper(T, BID, IN, N) :- in_scope(T), returned(T0, BID, _, IN, N0), T0 =< T, N is (-N0).

basket_stole(T, BID, IN, N) :- in_scope(T), basket(BID), prop(_, name, IN), findall(N0, basket_stole_helper(T, BID, IN, N0), L), sumlist(L, N), N>0.
basket_stole_helper(T, BID, IN, N) :- in_scope(T), stolen(T0, BID, _, IN, N), T0 =< T.
basket_stole_helper(T, BID, IN, N) :- in_scope(T), returned_stolen(T0, BID, _, IN, N0), T0 =< T, N is (-N0).

% can_buy(time, basket id, shelve id): a person with basket BID can buy from the shelf SID at time T
can_buy(T, BID, SID):- in_scope(T), measurement(BID, _, T, BP), measurement(SID, _, T, SP), m_distance(BP,SP,MD), MD is 1.

% m_distance(position 1, position 2, manhattan distance): manhattan distance MD from position 1 pos(X1,Y1) to position 2 pos(X2,Y2)
m_distance(pos(X1,Y1),pos(X2,Y2),MD):- X is (X1-X2), abs(X,XD), Y is (Y1-Y2), abs(Y,YD), MD is (XD + YD).

% removed_from_shelf(time, shelf id, item name, number of items): N items woth name IN were removed from shelf with id SID at time T
removed_from_shelf(T, SID, IN, N):- in_scope(T), T>0, T0 is T - 1, shelf_item_count(T, SID, IN, SN), shelf_item_count(T0, SID, IN, SN0), N is (SN0-SN), N>0.

% removed_from_shelf(time, shelf id, item name, number of items): N items woth name IN were removed from shelf with id SID at time T
returned_to_shelf(T, SID, IN, N):- in_scope(T), T>0, T0 is T - 1, shelf_item_count(T, SID, IN, SN), shelf_item_count(T0, SID, IN, SN0), N is (SN-SN0), N>0.

% calc_weight(item, number, price): calculates the weigth W of N items of item I
calc_weight(I, N, W):- prop(I, weight, IW), W is (IW*N).

% weight_change(time, basket id, weight): basket with id BID had a change of weight W at time T
weight_change(T, BID, W):- in_scope(T), T>0, T0 is T - 1, measurement(BID, BW, T, _), measurement(BID, BW0, T0, _), W is (BW-BW0).

% grabbed(time, basket id, shelf id, item name, number of items): basket with is BID grabbed N items with name IN from shelf with id SID at time T
grabbed(T, BID, SID, IN, N):- in_scope(T), removed_from_shelf(T, SID, IN, N), calc_weight(I, N, W), weight_change(T, BID, WC), WC>0, prop(I, name, IN), can_buy(T, BID, SID), abs(WC,W).

stole(T, BID, SID, IN, N):- in_scope(T), removed_from_shelf(T, SID, IN, N), can_buy(T, BID, SID), not(grabbed(T, BID, SID, IN, N)). 

% grabbed(time, basket id, shelf id, item name, number of items): basket with is BID returned N items with name IN from shelf with id SID at time T
returned(T, BID, SID, IN, N):- in_scope(T), returned_to_shelf(T, SID, IN, N), calc_weight(I, N, W), weight_change(T, BID, WC), WC<0, prop(I, name, IN), can_buy(T, BID, SID), abs(WC,W).

returned_stolen(T, BID, SID, IN, N):- in_scope(T), returned_to_shelf(T, SID, IN, N), not(returned(T, BID, SID, IN, N)).

% checkout_time(basket id, time): the checkout time T for basket BID
checkout_time(BID, T):- in_scope(T), basket(BID), exit(Pos), findall(T0, (measurement(BID, _, T0, Pos), in_scope(T0)), L), min_list(L,T).

% checkout_price(basket id, price): the checkout price P for basket BID
checkout_price(BID, P):- basket(BID), checkout_time(BID, CTime), ChkOut_Time is CTime, basket_price(ChkOut_Time, BID, P).

checkout_basket_has(BID, IN, N):- basket(BID), checkout_time(BID, CTime), ChkOut_Time is CTime, basket_has(ChkOut_Time, BID, IN, N).

checkout_basket_stole(BID, IN, N):- basket(BID), checkout_time(BID, CTime), ChkOut_Time is CTime, basket_stole(ChkOut_Time, BID, IN, N).


%in_scope(time): time is in the application time restrictions
in_scope(T):- findall(T0, measurement_raw(_, _, T0, _), L), min_list(L,Min), max_list(L,Max), between(Min, Max, T).


% Story
% mat a has weight 0 at time 0 at pos(0,0)
% measurement_raw(id, weight, time, position)
measurement_raw(s1, 40, 0, pos(2,1)). % 4 apples
measurement_raw(s2, 70, 0, pos(3,1)). % 7 bananas
measurement_raw(s3, 100, 0, pos(2,2)). % 5 carrots
measurement_raw(s4, 150, 0, pos(3,2)). % 5 dates
measurement_raw(s5, 30, 0, pos(2,3)). % 3 apples
measurement_raw(s6, 60, 0, pos(3,3)). % 3 carrots

% User 1 story
measurement_raw(b1, 0, 0, pos(0,0)). % user’s mat_id=b1
measurement_raw(b1, 0, 1, pos(1,0)).
measurement_raw(b1, 0, 2, pos(1,1)).
measurement_raw(b1, 10, 3, pos(1,1)). % get 1 apple from s1
measurement_raw(s1, 30, 3, pos(2,1)).

measurement_raw(b1, 10, 4, pos(1,2)).
measurement_raw(b1, 10, 5, pos(1,3)).
measurement_raw(b1, 30, 6, pos(1,3)). % get 2 apple from s5
measurement_raw(s5, 10, 6, pos(2,3)).

measurement_raw(b1, 30, 7, pos(1,4)).
measurement_raw(b1, 30, 8, pos(2,4)).
measurement_raw(b1, 30, 9, pos(3,4)).
measurement_raw(b1, 50, 10, pos(3,4)). % get 1 carrot from s6
measurement_raw(s6, 40, 10, pos(3,3)).

measurement_raw(b1, 40, 11, pos(3,5)).
measurement_raw(b1, 40, 12, pos(4,5)).
measurement_raw(b1, 40, 13, pos(5,5)). % checkout

% User 2 story
%% measurement_raw(b2, 0, 0, pos(-1,-1)).
measurement_raw(b2, 0, 10, pos(0,0)).
measurement_raw(b2, 0, 11, pos(0,1)).
measurement_raw(b2, 0, 12, pos(0,2)).
measurement_raw(b2, 0, 13, pos(1,2)).
measurement_raw(b2, 40, 14, pos(1,2)). % get 2 carrots from s3
measurement_raw(s3, 60, 14, pos(2,2)).

measurement_raw(b2, 40, 15, pos(1,3)).
measurement_raw(b2, 40, 16, pos(1,4)).
measurement_raw(b2, 40, 17, pos(2,4)).
measurement_raw(b2, 40, 18, pos(3,4)).
measurement_raw(b2, 40, 19, pos(4,4)).
measurement_raw(b2, 40, 20, pos(4,3)).
measurement_raw(b2, 40, 21, pos(4,2)).
measurement_raw(b2, 100, 22, pos(4,2)). % get 2 dates from s4
measurement_raw(s4, 90, 22, pos(3,2)).

measurement_raw(b2, 100, 23, pos(4,3)).
measurement_raw(b2, 100, 24, pos(4,2)).
measurement_raw(b2, 70, 25, pos(4,2)). % put back 1 date to s4
measurement_raw(s4, 120, 25, pos(3,2)).
measurement_raw(b2, 70, 26, pos(5,2)).
measurement_raw(b2, 70, 27, pos(5,3)).
measurement_raw(b2, 70, 28, pos(5,4)).
measurement_raw(b2, 70, 29, pos(5,5)). % checkout

measurement_raw(b2, 70, 50, pos(5,5)). % checkout




% Use measurement for actually retrieving values
measurement_c(ID, W, T, P):- in_scope(T), measurement(ID, W, T, P).

% Use measurement for actually retrieving values
measurement(ID, W, T, P):- mat_id(ID), measurement_raw(ID, W, T, P).
measurement(ID, W, T, P):- mat_id(ID), not(measurement_raw(ID, _, T, _)), T0 is T - 1, T >= -1,  measurement(ID, W, T0, P).

pos_in_store(X, Y):- sizeX(XS), MAX_X is XS, sizeY(YS), MAX_Y is YS, between(0,MAX_X,X), between(0,MAX_Y,Y).
pos_in_store(pos(X, Y)):- pos_in_store(X,Y).

is_in_store(M):- basket(M), measurement(M, _, _, P), pos_in_store(P).
is_in_store(M):- shelf(M, _), measurement(M, _, _, P), pos_in_store(P).
