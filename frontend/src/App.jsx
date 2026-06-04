import { useState, useEffect } from 'react'
import axios from 'axios'

function App() {
  const [notes, setNotes] = useState([])
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')

  // Read API URL from environment variables
  const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

  useEffect(() => {
    fetchNotes()
  }, [])

  const fetchNotes = async () => {
    try {
      const response = await axios.get(`${API_URL}/notes/`)
      setNotes(response.data)
    } catch (error) {
      console.error("Error fetching notes", error)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!title) return
    try {
      await axios.post(`${API_URL}/notes/`, { title, content })
      setTitle('')
      setContent('')
      fetchNotes()
    } catch (error) {
      console.error("Error creating note", error)
    }
  }

  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', fontFamily: 'sans-serif' }}>
      <h1>DevOps Notes App</h1>
      
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '20px' }}>
        <input 
          type="text" 
          placeholder="Note Title" 
          value={title} 
          onChange={(e) => setTitle(e.target.value)} 
          style={{ padding: '8px' }}
        />
        <textarea 
          placeholder="Note Content" 
          value={content} 
          onChange={(e) => setContent(e.target.value)}
          style={{ padding: '8px', minHeight: '60px' }}
        />
        <button type="submit" style={{ padding: '10px', backgroundColor: '#007bff', color: 'white', border: 'none' }}>
          Add Note
        </button>
      </form>

      <div>
        {notes.map(note => (
          <div key={note.id} style={{ border: '1px solid #ddd', padding: '10px', marginBottom: '10px', borderRadius: '5px' }}>
            <h3 style={{ margin: '0 0 10px 0' }}>{note.title}</h3>
            <p style={{ margin: 0 }}>{note.content}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

export default App