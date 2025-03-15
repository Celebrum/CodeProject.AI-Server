-- Create a sample table for FfeD
CREATE TABLE brain_parts (
    id SERIAL PRIMARY KEY,
    part_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO brain_parts (part_name, description) VALUES
('Cortex', 'Responsible for higher-order brain functions'),
('Cerebellum', 'Coordinates voluntary movements'),
('Brainstem', 'Controls basic body functions');
