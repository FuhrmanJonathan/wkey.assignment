# WKEY Enemy Spawner Assignment

## Overview

This project implements a scalable enemy spawning and movement system designed with performance and network efficiency as primary goals. The system uses a custom replication approach to minimize network traffic while maintaining smooth and responsive movement across clients.

For visualization, the demo is oriented in an *isometric perspective to make enemy movement and positioning easier to observe.

Enemies are implemented using simple square parts with randomized visual attributes generated deterministically, ensuring that all clients see consistent enemy variations without requiring additional replication data.

---

## Enemy Behavior

Enemies dynamically target the nearest player located within the platform bounds.

When approaching a player:

- Enemies chase the closest valid player  
- If slightly outside attack range, enemies perform a short dash  
- When within close proximity, enemies deal damage  

This behavior was chosen to create responsive enemy interactions while keeping server-side computation lightweight.

---

## Runtime Controls

A runtime UI allows modification of core spawning parameters:

- **Spawn Rate** — Controls how frequently enemies spawn  
- **Maximum Enemy Count** — Limits the number of active enemies  

Setting the spawn limit to **0** immediately clears all active enemies, serving as a functional equivalent to a kill-all control.

## Replication Strategy

Enemy movement replication was implemented using a custom system designed to minimize bandwidth usage.

Only minimal state data is transmitted:

- Unique object identifiers  
- Model keys  
- Quantized position values  

Updates are sent only when movement exceeds a defined threshold. This prevents unnecessary replication while keeping positional updates accurate.

On the client side, enemy visuals are reconstructed locally and smoothed using interpolation and light prediction. This improves perceived motion smoothness without increasing network load.

This approach was chosen to reduce the network receive cost while maintaining consistent movement behavior across all clients.

## Performance Considerations

Performance was prioritized throughout development to support scalability as enemy counts increase.

Key strategies included:

- Threshold-based movement updates  
- Quantized positional data  
- Minimal replication payload size  
- Client-side smoothing of movement  

These decisions reduce network traffic and help maintain stable performance under higher object counts.

## Design Focus

The primary focus of this implementation was:

- Maintaining low network overhead  
- Keeping systems predictable and consistent  
- Supporting scalability through efficient replication  
- Ensuring deterministic enemy variation across clients  

Development effort was intentionally concentrated on system efficiency rather than visual complexity.

## Links

**GitHub Repository**  
https://github.com/FuhrmanJonathan/wkey.assignment  

**Published Roblox Game**  
https://www.roblox.com/games/124440323314227/wkey-assignment  