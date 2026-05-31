global using System;
global using System.Collections.Generic;
global using System.Linq;
global using System.Threading.Tasks;
global using Microsoft.EntityFrameworkCore;
global using Microsoft.EntityFrameworkCore.Metadata.Builders;
global using System.ComponentModel.DataAnnotations;
global using System.ComponentModel.DataAnnotations.Schema;
global using Supabase;


// Bridge the two DB Context naming styles
global using ApplicationDbContext = Souvenir_Collection_Backend.Data.AppDbContext;
global using AppDbContext = Souvenir_Collection_Backend.Data.AppDbContext;

// Unify the project namespaces to resolve spelling variants
global using Souvenir_Collection_Backend.Models;
global using Sovenire_Collenction_Backend.Models;
global using Souvenir.Backend.Models;

global using Souvenir_Collection_Backend.Services;
global using Sovenire_Collenction_Backend.Services;
global using Souvenir_Collection_Backend.Data;
global using Sovenire_Collenction_Backend.DTOs.Auth;
global using Sovenire_Collenction_Backend.DTOs.Product;
global using Sovenire_Collenction_Backend.DTOs.Promotion;
global using Sovenire_Collenction_Backend.DTOs.Collection;
global using Sovenire_Collenction_Backend.DTOs.Order;
global using Sovenire_Collenction_Backend.DTOs.Artisan;
global using Sovenire_Collenction_Backend.DTOs.Admin;
global using Souvenir_Collection_Backend.Enums;
global using Sovenire_Collenction_Backend.Enums;

