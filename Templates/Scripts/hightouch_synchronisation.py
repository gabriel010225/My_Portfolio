import requests
from typing import List, Dict
from datetime import datetime

def trigger_sync(sync_id: str, 
                api_token: str,
                base_url: str = "https://api.hightouch.com/api/v1",
                clear_and_fill: bool = False,
                reset_cdc: bool = False,
                full_resync: bool = False) -> Dict[str, str]:
    url = f"{base_url}/syncs/{sync_id}/trigger"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    payload = {
        "clearAndFill": str(clear_and_fill).lower(),
        "resetCDC": str(reset_cdc).lower(),
        "fullResync": str(full_resync).lower()
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200:
            return {"status": "success", "message": "Synchronisation réussie"}
        else:
            return {"status": "error", "message": f"Erreur {response.status_code}: {response.text}"}
    except requests.exceptions.RequestException as e:
        return {"status": "error", "message": f"Erreur de connexion: {str(e)}"}

def trigger_syncs_sequential(sync_ids: List[str], api_token: str) -> None:
    start_time = datetime.now()
    
    print("🚀 Démarrage des synchronisations...")
    print("-" * 50)

    for sync_id in sync_ids:
        print(f"⏳ Synchronisation de {sync_id} en cours...")
        result = trigger_sync(sync_id, api_token)
        
        if result["status"] == "success":
            print(f"✅ {sync_id}: {result['message']}")
        else:
            print(f"❌ {sync_id}: {result['message']}")
        print("-" * 50)
        
    duration = (datetime.now() - start_time).total_seconds()
    print(f"⏱️  Durée totale: {duration:.2f} secondes")

if __name__ == "__main__":
    SYNC_IDS = [""]
    API_TOKEN = ""
    
    trigger_syncs_sequential(SYNC_IDS, API_TOKEN)