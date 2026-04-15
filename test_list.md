# Test Cases

## 1. Attach UE to Network
- **TC-001**: Fail when UE ID is not provided  
- **TC-002**: Fail when UE ID is invalid  
- **TC-003**: Fail when UE is already connected  
- **TC-004**: Succeed when valid UE ID is provided and bearer ID = 9  

## 2. Detach UE from Network
- **TC-005**: Succeed with valid UE ID  
- **TC-006**: Fail when UE ID is invalid  
- **TC-007**: Fail when UE is not connected  
- **TC-008**: Fail when UE ID is not provided  

## 3. Start Data Transfer
- **TC-009**: Allow transfer only in DL  
- **TC-010**: Fail when transfer speed is invalid  
- **TC-011**: Fail when UE ID is invalid  
- **TC-012**: Fail when bearer ID is inactive  
- **TC-013**: Succeed with valid data  
- **TC-014**: Fail when UE ID is not provided  
- **TC-015**: Fail when bearer ID is not provided  
- **TC-016**: Fail when transfer speed is not provided  

## 4. Check Transfer Status
- **TC-017**: Retrieve status for a specific bearer  
- **TC-018**: Retrieve status for all bearers  
- **TC-019**: Default unit is kbps  
- **TC-020**: Fail when bearer ID is invalid  
- **TC-021**: Fail when UE ID is invalid  
- **TC-022**: Fail when UE ID is not provided  

## 5. Finish Data Transfer
- **TC-023**: Finish transfer for a specific bearer  
- **TC-024**: Finish transfer for all bearers  
- **TC-025**: Fail when bearer ID is invalid  
- **TC-026**: Fail when UE ID is invalid  
- **TC-027**: Fail when UE ID is not provided  

## 6. Add Transport Channel
- **TC-028**: Fail when UE ID is invalid  
- **TC-029**: Fail when bearer ID is invalid  
- **TC-030**: Fail when bearer ID already exists  
- **TC-031**: Succeed with valid data  
- **TC-032**: Fail when UE ID is not provided  
- **TC-033**: Fail when bearer ID is not provided  

## 7. Check Connected Bearers
- **TC-034**: Fail when UE ID is invalid  
- **TC-035**: Return correct list of connected bearers  
- **TC-036**: Fail when UE ID is not provided  

## 8. Delete Transport Channel
- **TC-037**: Fail when UE ID is invalid  
- **TC-038**: Fail when bearer ID is invalid  
- **TC-039**: Fail when bearer ID is inactive  
- **TC-040**: Allow deletion of default bearer  
- **TC-041**: Succeed with valid data  
- **TC-042**: Fail when UE ID is not provided  
- **TC-043**: Fail when bearer ID is not provided  

## 9. Reset Simulator
- **TC-044**: Reset affects attached UEs  
- **TC-045**: Reset affects ongoing data transfers  
- **TC-046**: Reset affects transport channels  
