extends Node

var money : float = 0 :
	set(value):
		var diff = abs(value - money)
		if value > money:
			money = value
			SignalBus.money_collected.emit(diff)
		elif value < money:
			money = value
			SignalBus.money_spent.emit(diff)
