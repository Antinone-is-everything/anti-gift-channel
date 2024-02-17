package main

import (
	"encoding/json"
	"fmt"
	"log"

	//"os"

	"./outlinesdk"
)

type UsageInfo struct {
	BytesTransferredByUserID map[string]int64 `json:"bytesTransferredByUserId,omitempty"`
}

func main() {
	// Replace "https://your-outline-server-url" with your actual Outline server URL
	serverURL := "https://example.com:1222/l9hBqsfsfsvjfbBczTo4jehg"
	cert256 := "6EBD04FFE1E67366E2D3827943F2BE468C972063B34CE8318DA90D4C114E0F17"

	client, err := outlinesdk.NewClient(serverURL, cert256)
	if err != nil {
		log.Fatal("Error creating Outline client:", err)
	}
	// Server Info
	//var Sinfo Serverinfo
	info, err := client.GetServerInfo()
	if err != nil {
		log.Fatal("Error getting Serverinfo:", err)
	}

	fmt.Printf("Server Create time : %v\n", info.CreatedTime())
	marshaled, err := json.MarshalIndent(info, "", "   ")
	if err != nil {
		log.Fatalf("marshaling error: %s", err)
	}
	fmt.Println(string(marshaled))

	// encInfo := json.NewEncoder(os.Stdout)
	// if err := encInfo.Encode(info); err != nil {
	// 	fmt.Printf("error encoding struct into JSON: %v\n", err)
	// }

	//fmt.Println("Server Info:", Sinfo)
	// Get keys
	keys, err := client.GetAccessKeys()
	if err != nil {
		log.Fatal("Error getting keys:", err)
	}

	// keylist, err := json.MarshalIndent(keys, "", "   ")
	// if err != nil {
	// 	log.Fatalf("marshaling error: %s", err)
	// }
	// fmt.Println(string(keylist))
	// encKeys := json.NewEncoder(os.Stdout)
	// if err := encKeys.Encode(keys); err != nil {
	// 	fmt.Printf("error encoding struct into JSON: %v\n", err)
	// }

	usage, err := client.GetUsageMetrics()
	if err != nil {
		log.Fatal("Error getting usage:", err)
	}
	// usageMetric, err := json.MarshalIndent(usage, "", "   ")
	// if err != nil {
	// 	log.Fatalf("marshaling error: %s", err)
	// }
	// fmt.Println(string(usageMetric))

	// AKDL, err := client.GetAccessKey("35")
	// if err != nil {
	// 	log.Fatal("Error getting Serverinfo:", err)
	// }

	// fmt.Printf("Access Key Data Limit : %v\n", *AKDL)
	// AKDLenc, err := json.MarshalIndent(AKDL, "", "   ")
	// if err != nil {
	// 	log.Fatalf("marshaling error: %s", err)
	// }
	// fmt.Println(string(AKDLenc))

	for userID, bytesTransferred := range *usage {
		for _, item := range *keys {
			// Check if the ID is equal to "226"
			if item.ID == userID {

				accessLimit, err := client.GetAccessKey(userID)
				if err != nil {
					log.Fatal("Error getting Serverinfo:", err)
				}

				if bytesTransferred >= accessLimit.DataLimit.Bytes {

					fmt.Printf("UserID: %s , UserName: %s , Data Limit: %.2f MB, Bytes Transferred: %.2f MB, Data transfer is finished!\n", userID, item.Name, float64(accessLimit.DataLimit.Bytes/(1024*1024)), float64(bytesTransferred/(1024*1024)))

				} else {
					fmt.Printf("UserID: %s , UserName: %s , Data Limit: %.2f MB, Bytes Transferred: %.2f MB\n", userID, item.Name, float64(accessLimit.DataLimit.Bytes/(1024*1024)), float64(bytesTransferred/(1024*1024)))

				}

			}
		}

	}

}
