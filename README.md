# CRDT or Conflict-free Replicated Data Type in Swift 5.5
Convergent and Commutative Replicated Data Types or
Conflict-free replicated data type

here, the state-based CRDTs was implemented only.
through LWW-Element-Set (Last-Write-Wins-Element-Set)

Jul, 2021, by Sungwook Kim


## NOTE
I have **my updated version** of this but not public: this project in public has lots of room to improve in both **performance and code clarity**.
 Because this project had been created **against the clock** like 3 hours.

  **I usually do not put my hard-earned codes to the public: hard-earned codes which have been repeatedly tested for a long period**
This project is supposed to give a clear idea of how CRDT can be succinctly implemented in Swift5.5.


**And this whole project was made in `3-4 hours` as the result of a code challenge.**
 operator == and === and !== is a kind of makeshift which was invented in few minutes of thought, running against the clock.
 Therefore, there shall be a much better implementation than this.

**I don't think that code challenges being done within a given time frame like 3-4 hours would better give insight about the candidate.**
Especially when the candidate is a mathematical mind, there shall be many alternative ways to implement the CRDT
 or any data structure existing. The person shall surely be inundated with lots of comparisons of all implementations.
Because a candidate who only considers one way or who has experience in a similar graph data type will outperform.
I think the portfolio alone should give better information about the candidate than single or multiple code challenges.


## Version
1.0.0-alpha version build 1

## CRDT Data Type Usage
- Database
- messaging apps

## CRDT Charactistics

- Commutativity (a+b=b+a)
- Associativity (a+(b+c)=(a+b)+c)
- Idempotence (a+a=a)

## Reference
https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)

## TESTS in this project

- SungW_CRDT_GroupPropertyTests: All Commutative Group properties including Idempotency
- SungW_CRDT_Primitive_Tests: primitive tests for LWWSet



