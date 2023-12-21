FUNCTION func(a, b, op)
implicit none
integer :: a, b
integer op

select CASE (op)
CASE (1)
func = a + b
Case (2)
func = a - b
case (3)
func = a * b
case DEFAULT
func = a / b
end select
END FUNCTION func
