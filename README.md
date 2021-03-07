| Op Code | Tx/Rx (Client) |   Short Description    |                  Example                   |                                         Value                                         |
| :-----: | :------------: | :--------------------: | :----------------------------------------: | :-----------------------------------------------------------------------------------: |
|    0    |       Rx       | Intial connect payload |                                            |      { op: `0`, d: { heartbeat_interval: `30000` `(interval time in millis)` } }      |
|    1    |       Tx       |     Send Heartbeat     |                { op: `1` }                 |                                      { op: `1` }                                      |
|    2    |       Rx       |     Heartbeat ACK      |                                            |                                      { op: `2` }                                      |
|    3    |       Tx       |      Send Message      |  { op: `3`, d: { message: `"Hello!"` } }   |                               **_Refer to Op Code 4_**                                |
|    4    |       Rx       |    Recieve Message     |                                            |             { op: `4`, d: { message: `"Hello!"`, sender: `"John Doe"` } }             |
|    5    |       Rx       |   Update Client List   |                                            | { op: `5`, d: { client_link: [ { pid: `"#PID<0.0.0>"`, nickname: `"John Doe"` } ] } } |
|    6    |       Tx       |      Set Nickname      | { op: `6`, d: { nickname: `"John Doe"` } } |                               **_Refer to OP Code 7_**                                |
|    7    |       Rx       |    Update Nickname     |                                            |           { op: `7`, d: { pid: `"#PID<0.0.0>"`, nickname: `"John Doe"` } }            |
