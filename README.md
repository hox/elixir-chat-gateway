| Op Code | Tx/Rx (Client) |   Short Description    |                 Example                 |                                    Value                                    |
| :-----: | :------------: | :--------------------: | :-------------------------------------: | :-------------------------------------------------------------------------: |
|    0    |       Rx       | Intial connect payload |                                         | { op: `0`, d: { heartbeat_interval: `30000` `(interval time in millis)` } } |
|    1    |       Tx       |     Send Heartbeat     |               { op: `1` }               |                                 { op: `1` }                                 |
|    2    |       Rx       |     Heartbeat ACK      |                                         |                                 { op: `2` }                                 |
|    3    |       Tx       |      Send Message      | { op: `3`, d: { message: `"Hello!"` } } |                          **_Refer to Op Code 4_**                           |
|    4    |       Rx       |    Recieve Message     |                                         |        { op: `4`, d: { message: `"Hello!"`, sender: `"John Doe"` } }        |
